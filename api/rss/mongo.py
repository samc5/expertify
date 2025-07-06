from pymongo import MongoClient, ReturnDocument
from datetime import datetime
import bcrypt
from dotenv import load_dotenv
import os
from bson import ObjectId
import dateutil.parser
# set a string equal to the contents of mongodbpassword.txt
load_dotenv()
connection_string = os.getenv("CONNECTION_STRING")

def connect_to_collection(collection_name):
    """
    Connects to the MongoDB collection specified by collection_name.
    Returns a collection object.
    """
    uri = connection_string
    client = MongoClient(uri)
    db = client["expertify"]
    collection = db[collection_name]
    return collection


def add_feed(map):
    collection = connect_to_collection("feeds")
    try:
        collection.replace_one({'url': map['url']}, map, upsert=True)  
        print("upserted")
        #db["test"].find_all()
    except Exception as e:
        print(e)

def add_feeds(maps):
    collection = connect_to_collection("feeds")
    try:
        for map in maps:
            existing_doc = collection.find_one({'url': map['url']})
            if existing_doc:
                map['subscribers_count'] = existing_doc.get('subscribers_count', 0)
                updated_doc = {**existing_doc, **map}
                collection.replace_one({'url': map['url']}, updated_doc, upsert=True)  
            else:
                collection.replace_one({'url': map['url']}, map, upsert=True)
            print("upserted")
    except Exception as e:
        print(e)

def check_user(user):
    """
    Returns the info about a user, given a dictionary with user['email'] and user['password']
    """
    collection = connect_to_collection("Users")
    try:
        usr = collection.find_one({"email": user['email'], "password": user['password']})
        return usr
    except Exception as e:
        print(e)


def check_email(email):
    """
    Returns True if the entered email is already in the Users database, False otherwise
    """
    collection = connect_to_collection("Users")
    try:
        usr = collection.find_one({"email": email})
        if usr:
            return True
        return False
    except Exception as e:
        print(e)

def check_login(email, pw):
    collection = connect_to_collection("Users")
    try:
        usr = collection.find_one({"email": email})
        if usr:
            if bcrypt.checkpw(pw.encode('utf-8'),usr['password']):
                return usr['_id']
            else:
                return "No Match"
    except Exception as e:
        print(e)

def get_email(user_id):
    collection = connect_to_collection("Users")
    try:
        usr = collection.find_one({"_id": ObjectId(user_id)})
        if usr:
            return usr['email']
    except Exception as e:
        print(e)

def hash(password):
    """
    Salts and hashes a given password with bcrypt
    """
    bytes = password.encode('utf-8') 
    salt = bcrypt.gensalt() 
    hash = bcrypt.hashpw(bytes, salt) 
    return hash

def signUp(email, hash):
    if check_email(email):
        print("check email foudn ttue")
        return None
    collection = connect_to_collection("Users")
    try:
        res = collection.insert_one({"email": email, "password": hash})
        return res.inserted_id
    except Exception as e:
        print(e)

def add_user_link(user_id, blog):
    collection = connect_to_collection("UserData")
    try:
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        #collection.replace_one({'url': blog['url']}, blog, upsert=True)
        collection.update_one(
        {'url': blog['url']},
        {
            '$setOnInsert': {'subscribers_count': 0},  # Initialize count if document is new
            '$inc': {'subscribers_count': 1}  # Increment the subscribers count
        },
    upsert=True
)
    except Exception as e:
        print(e)

def add_user_category_link(user_id, blog, category):
    collection = connect_to_collection("UserData")
    try:
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {f"Categories.{category}": blog['url']}}, upsert=True)
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        #collection.replace_one({'url': blog['url']}, blog, upsert=True)
    except Exception as e:
        print(e)

def add_user_categories_link(user_id, blog, categories):
    collection = connect_to_collection("UserData")
    try:
        for category in categories:
            collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {f"Categories.{category}": blog['url']}}, upsert=True)
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        #collection.replace_one({'url': blog['url']}, blog, upsert=True)
        collection.update_one(
        {'url': blog['url']},
        { # Initialize count if document is new
            '$inc': {'subscribers_count': 1}  # Increment the subscribers count
        },
    upsert=True
)
    except Exception as e:
        print(e)

def delete_user_link(user_id, url):
    collection = connect_to_collection("UserData")
    try:
        user_data = collection.find_one({"user_id": ObjectId(user_id)})
        categories = user_data.get("Categories", {})
        update_query = {"$pull": {"feeds": url}}
        for category_name, _ in categories.items():
            update_query["$pull"][f"Categories.{category_name}"] = url
        collection.update_one({"user_id": ObjectId(user_id)}, update_query)
        collection = db["feeds"]
        collection.update_one(
        {'url': url},
        {   '$inc': {'subscribers_count': -1}}
        )
    except Exception as e:
        print(e)        

def get_user_categories(user_id):
    collection = connect_to_collection("UserData")
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        if user:
            category_names = list(user.get("Categories", {}).keys())
            return category_names
        return []
    except Exception as e:
        print(e)

def get_user_category_links(user_id, category):
    collection = connect_to_collection("UserData")
    try:
         user = collection.find_one({"user_id": ObjectId(user_id)})
         links = user['Categories'][category]
         return links
    except Exception as e:
        print(f'Exception: {e}')


def get_user_feeds(user_id):
    collection = connect_to_collection("UserData")
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        return user['feeds']
    except Exception as e:
        print(e)

def check_user_feed(user_id, url):
    collection = connect_to_collection("UserData")
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        if user is None:
            return False
        return url in user['feeds']
    except Exception as e:
        print(e)

def fetch_all_feeds():
    collection = connect_to_collection("feeds")
    try:
        feeds = collection.find()
        return feeds
    except Exception as e:
        print(e)

def fetch_user_bookmarks(user_id):
    collection = connect_to_collection("UserData")
    search = []
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        if 'saved' in user:
            for i in user['saved']:
                print(i)
                search.append(i)
            return get_attached_articles(search)
    except:
        pass

def get_attached_articles(search):
    collection = connect_to_collection("SavedArticles")
    res = []
    try:
        for i in search:
            res.append(collection.find_one({"_id": ObjectId(i)}))
        return res
    except Exception as e:
        print(e)


def convert_to_date(date_str):
    formats = ['%a, %d %b %Y %H:%M:%S', '%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S.%fZ', '%Y-%m-%dT%H:%M:%SZ',
    '%Y-%m-%dT%H:%M:%S%z','%Y-%m-%d %H:%M:%S',       
    '%Y-%m-%dT%H:%M:%S.%f%z', '%Y-%m-%dT%H:%M:%SZ', '%Y-%m-%dT%H:%M:%S.000Z',
    '%Y-%b-%d %H:%M:%S',    
    '%Y-%B-%d %H:%M:%S',  '%Y-%m-%dT%H:%M:%S.%fZ', 'Y-%m-%dT%H:%M:%SZ', '%Y-%m-%dT%H:%M:%S%z', '%Y-%m-%dT%H:%M:%S+00:00'      
    ]
    #2024-05-21T14:04:52+00:00
    if date_str:
        if ' ' in date_str:
            date_str = date_str[:date_str.rindex(' ')]
        if date_str == '':
            return datetime.utcfromtimestamp(0)
    for date_format in formats:
        try:
            datetime_object = datetime.strptime(date_str, date_format)
            return datetime_object
        except ValueError:
       #     print(f"bad: {date_str}, {date_format}")
            continue
    return datetime.utcfromtimestamp(0)


def aggregate(pipeline_input):
    collection = connect_to_collection("feeds")
    x = list(collection.aggregate(pipeline_input))
    return x

def save_article(blog_entry):

    collection = connect_to_collection("SavedArticles")
    try:
        saved_id = collection.find_one_and_replace(
            {'url': blog_entry['url']},
            blog_entry,
            upsert=True,
            return_document=ReturnDocument.AFTER
        )
        return saved_id
    except Exception as e:
        print(f"Mongo error: {e}")

def save_personal(blog_entry, user_id):
    collection = connect_to_collection("UserData")
    try:
        article = save_article(blog_entry)
        user = collection.find_one({"user_id": ObjectId(user_id)})
        if user and article:
            collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"saved": article['_id']}}, upsert=True)
    except Exception as e:
        print(f"Mongo error: {e}")

def time_last_crawl():
    collection = connect_to_collection("Updates")
    try:
        last_crawl = collection.find_one({}, sort=[("time", -1)])
        if last_crawl:
            return last_crawl['time']
        return None
    except Exception as e:
        print(e)
