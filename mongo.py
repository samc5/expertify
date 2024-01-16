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
        client.admin.command('ping')
        print('pinged')
        #collection.find_one({'url': map['url']})
        
        collection.replace_one({'url': map['url']}, map, upsert=True)    #print("Pinged your deployment. You successfully connected to MongoDB!")
        print("upserted")
        #db["test"].find_all()
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

    
def convert_to_date(date_str):
    date_str = date_str[:date_str.rindex(' ')]
    datetime_object = datetime.strptime(date_str, '%a, %d %b %Y %H:%M:%S')
    return datetime_object


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

for i in aggregate(pipeline2):
    print("\n")
    #print(i)
    print(i['publication_name'])
    print(i['title'])
    print(i['date'])
    #print(i['title'])
    #print(i['dates'])
    #print(i['titles'])
    print(i['value'])
