import mongo
import parser
from datetime import datetime
from time import sleep
def certify_crawl():
    collection = mongo.connect_to_collection('Updates')
    collection.insert_one({
        "time": datetime.now(),
        "message": "Crawl finished successfully."
    })

url_pipeline = [
    {
        "$project": {
            "url": 1
        }
    }
]

while(1):
    print("Looping around...")
    urls = mongo.aggregate(url_pipeline)
    feed_dicts = []
    for i in urls:
        print(f"Processing URL: {i['url']}")
        sleep(0.5)
        feed_dicts.append(parser.construct_feed_dict(i['url']))
    mongo.add_feeds(feed_dicts)
    certify_crawl()