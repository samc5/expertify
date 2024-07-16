import mongo
import parser

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
    feed_dicts = [parser.construct_feed_dict(i['url']) for i in urls]
    mongo.add_feeds(feed_dicts)