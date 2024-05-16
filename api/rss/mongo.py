from pymongo.mongo_client import MongoClient
from datetime import datetime
import bcrypt
from dotenv import load_dotenv
import os
from bson import ObjectId
import dateutil.parser
# set a string equal to the contents of mongodbpassword.txt
load_dotenv()
password = os.getenv("MONGO_PASSWORD")




def add_feed(map):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["feeds"]
    
    try:
        collection.replace_one({'url': map['url']}, map, upsert=True)    #print("Pinged your deployment. You successfully connected to MongoDB!")
        print("upserted")
        #db["test"].find_all()
    except Exception as e:
        print(e)

def add_feeds(maps):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["feeds"]
    #print(maps)
    try:
        for map in maps:
            #print("start")
            #print(map)
            collection.replace_one({'url': map['url']}, map, upsert=True)    #print("Pinged your deployment. You successfully connected to MongoDB!")
            print("upserted")
    except Exception as e:
        print(e)

def check_user(user):
    """
    Returns the info about a user, given a dictionary with user['email'] and user['password']
    """
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["Users"]
    try:
        usr = collection.find_one({"email": user['email'], "password": user['password']})
        return usr
    except Exception as e:
        print(e)


def check_email(email):
    """
    Returns True if the entered email is already in the Users database, False otherwise
    """
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["Users"]
    try:
        usr = collection.find_one({"email": email})
        if usr:
            return True
        return False
    except Exception as e:
        print(e)

def check_login(email, pw):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["Users"]
    try:
        usr = collection.find_one({"email": email})
        if usr:
            if bcrypt.checkpw(pw.encode('utf-8'),usr['password']):
                return usr['_id']
            else:
                return "No Match"
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
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["Users"]
    try:
        res = collection.insert_one({"email": email, "password": hash})
        return res.inserted_id
    except Exception as e:
        print(e)

def add_user_link(user_id, blog):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]  
    try:
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        collection.replace_one({'url': blog['url']}, blog, upsert=True)
    except Exception as e:
        print(e)

def add_user_category_link(user_id, blog, category):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {f"Categories.{category}": blog['url']}}, upsert=True)
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        collection.replace_one({'url': blog['url']}, blog, upsert=True)
    except Exception as e:
        print(e)

def add_user_categories_link(user_id, blog, categories):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        for category in categories:
            collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {f"Categories.{category}": blog['url']}}, upsert=True)
        collection.update_one({"user_id": ObjectId(user_id)}, {"$addToSet": {"feeds": blog['url']}}, upsert=True)
        collection = db["feeds"]
        collection.replace_one({'url': blog['url']}, blog, upsert=True)
    except Exception as e:
        print(e)

def delete_user_link(user_id, url):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        user_data = collection.find_one({"user_id": ObjectId(user_id)})
        categories = user_data.get("Categories", {})
        update_query = {"$pull": {"feeds": url}}
        for category_name, _ in categories.items():
            update_query["$pull"][f"Categories.{category_name}"] = url
        collection.update_one({"user_id": ObjectId(user_id)}, update_query)


        
    except Exception as e:
        print(e)        

def get_user_categories(user_id):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        category_names = list(user.get("Categories", {}).keys())
        return category_names
    except Exception as e:
        print(e)

def get_user_category_links(user_id, category):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
         user = collection.find_one({"user_id": ObjectId(user_id)})
         links = user['Categories'][category]
         return links
    except Exception as e:
        print(f'Exception: {e}')


def get_user_feeds(user_id):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        return user['feeds']
    except Exception as e:
        print(e)

def check_user_feed(user_id, url):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        if user is None:
            return False
        return url in user['feeds']
    except Exception as e:
        print(e)

def fetch_all_feeds():
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["Users"]
    try:
       pass
    except Exception as e:
        print(e)
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["feeds"]
    try:
        feeds = collection.find()
        return feeds
    except Exception as e:
        print(e)



def convert_to_date(date_str):
    formats = ['%a, %d %b %Y %H:%M:%S', '%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S.%fZ']
    if date_str:
        if ' ' in date_str:
            date_str = date_str[:date_str.rindex(' ')]
        else:
            print(date_str)
    for date_format in formats:
        try:
            datetime_object = datetime.strptime(date_str, date_format)
            return datetime_object
        except ValueError:
            pass
    
    # If none of the formats match, return datetime from the beginning of Unix time
    

# pipeline = [
    
#     {"$unwind": "$dates"},
#     {"$sort": {"dates": -1}},
#     {"$limit": 5},
        
# ]



# pipeline2 = [
    
#     {
#         "$project": {
#             "_id": 1,
#             "title": 1,
#             "titles": 1,
#             "values": 1,
#             "dates": 1,
#             "article": {
#                 "$zip": {
#                     "inputs": ["$titles", "$values", "$dates"],
#                 }
#             }
#         }
#     },
#     {"$unwind": "$article"},

#     {
#         "$project": {
#             "_id": 1,
#             "publication_name": "$title",
#             "title": {
#                 "$arrayElemAt": ["$article", 0]
#             },
#             "value": {
#                 "$arrayElemAt": ["$article", 1]
#             },
#             "date": {
#                 "$arrayElemAt": ["$article", 2]
#             }
#         }
#     },
#     {"$sort": {"date": -1}},
#     {"$limit": 25}
# ]

def aggregate(pipeline_input):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["feeds"]
    x = list(collection.aggregate(pipeline_input))
    return x


# for i in aggregate(pipeline2):
#     print("\n")
#     #print(i)
#     print(i['publication_name'])
#     print(i['title'])
#     print(i['date'])
#     #print(i['title'])
#     #print(i['dates'])
    #print(i['titles'])
    #print(i['value'])
