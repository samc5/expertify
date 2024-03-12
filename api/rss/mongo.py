from pymongo.mongo_client import MongoClient
from datetime import datetime
import bcrypt
from dotenv import load_dotenv
import os
from bson import ObjectId
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

def get_user_feeds(user_id):
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"
    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["UserData"]
    try:
        user = collection.find_one({"user_id": ObjectId(user_id)})
        #print(user)
        return user['feeds']
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




    
# def convert_to_date(date_str):
#     #2024-01-25 03:59:03
#     date_str = date_str[:date_str.rindex(' ')]
#     try:
#         datetime_object = datetime.strptime(date_str, '%a, %d %b %Y %H:%M:%S')
#     except:
#         datetime_object = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
#     return datetime_object


def convert_to_date(date_str):
    formats = ['%a, %d %b %Y %H:%M:%S', '%Y-%m-%d %H:%M:%S']
    if date_str:
        date_str = date_str[:date_str.rindex(' ')]
    for date_format in formats:
        try:
            datetime_object = datetime.strptime(date_str, date_format)
            return datetime_object
        except ValueError:
            pass
    
    # If none of the formats match, return datetime from the beginning of Unix time
    return datetime.utcfromtimestamp(0)

# pipeline = [
    
#     {"$unwind": "$dates"},
#     {"$sort": {"dates": -1}},
#     {"$limit": 5},
        
# ]



pipeline2 = [
    
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "titles": 1,
            "values": 1,
            "dates": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates"],
                }
            }
        }
    },
    {"$unwind": "$article"},

    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 25}
]

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