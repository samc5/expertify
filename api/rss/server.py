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
    # count = 1
    # for i in feed_dicts:
    #     # if count % 50 == 0:
    #     #     print(i)
    #     # count += 1
    mongo.add_feeds(feed_dicts)