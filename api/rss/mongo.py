from pymongo.mongo_client import MongoClient
from datetime import datetime
# set a string equal to the contents of mongodbpassword.txt





def add_feed(map):
    with open("mongodbpassword.txt", "r") as file:
        password = file.read()
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
    with open("mongodbpassword.txt", "r") as file:
        password = file.read()
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


def fetch_all_feeds():
    with open("mongodbpassword.txt", "r") as file:
        password = file.read()
    uri = f"mongodb+srv://samc5:{password}@bb-app.qmx5tog.mongodb.net/?retryWrites=true&w=majority"


    client = MongoClient(uri)
    db = client["bb-app"]
    collection = db["feeds"]
    try:
        feeds = collection.find()
        return feeds
    except Exception as e:
        print(e)

def ten_most_recent():
    feeds = fetch_all_feeds()

    
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
    with open("mongodbpassword.txt", "r") as file:
        password = file.read()
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
