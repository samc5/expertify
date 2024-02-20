from flask import Flask, request, jsonify
import os
from ariadne import load_schema_from_path, make_executable_schema, \
    graphql_sync, snake_case_fallback_resolvers, ObjectType
#from ariadne.constants import PLAYGROUND_HTML

from ariadne import convert_kwargs_to_snake_case
import mongo
import parser

app = Flask(__name__)
app.app_context().push()
basedir = os.path.abspath(os.path.dirname(__file__))



@app.after_request
def after_request(response):
  response.headers.add('Access-Control-Allow-Origin', '*')
  response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
  response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
  return response

pipeline2 = [
    
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates", "$links", "$authors"],
                }
            }
        }
    },
    {"$unwind": "$article"},

    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "url": 1,
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            },
            "link": {
                "$arrayElemAt": ["$article", 3]
            },
            "author": {
                "$arrayElemAt": ["$article", 4]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 25}
]

url_pipeline = [
    {
        "$project": {
            "url": 1
        }
    }
]

def pub_pipeline(url):
    return [
    {
        "$match": {
            "url": url 
        }
    },
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates", "$links", "$authors"],
                }
            }
        }
    },
    {"$unwind": "$article"},
    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "url": 1,
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            },
            "link": {
                "$arrayElemAt": ["$article", 3]
            },
            "author": {
                "$arrayElemAt": ["$article", 4]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 25}
]



#Substacks = ["https://www.awritersnotebook.org/feed", "https://yearofwritingdangerously.substack.com/feed", "https://news.manifold.markets/feed", "https://theadvancescout.substack.com/feed", "https://www.aisnakeoil.com/feed", "https://ryanjakubowski.substack.com/feed", "https://aquaimperium.substack.com/feed", "https://www.astralcodexten.com/feed", "https://www.briefingbook.info/feed", "https://poulos.substack.com/feed", "https://channelsofinfluence.substack.com/feed", "https://www.counteroffensive.news/feed", "https://cupofcoffee.substack.com/feed", "https://dhaaruni.substack.com/feed", "https://www.distilled.earth/feed", "https://danieldrezner.substack.com/feed", "https://theeggandtherock.com/feed", "https://gelliottmorris.substack.com/feed", "https://www.experimental-history.com/feed", "https://mileskellerman.substack.com/feed", "https://forklightning.substack.com/feed", "https://www.forkingpaths.co/feed", "https://herdingcatsnj.substack.com/feed", "https://hypertextjournal.substack.com/feed", "https://insidemedicine.substack.com/feed", "https://www.theinternationalcorrespondent.com/feed", "https://joeblogs.joeposnanski.com/feed", "https://www.jonstokes.com/feed", "https://www.liberalpatriot.com/feed", "https://mollyknight.substack.com/feed", "https://pmarca.substack.com/feed", "https://garymarcus.substack.com/feed", "https://jonathanstea.substack.com/feed", "https://www.mod171.com/feed", "https://www.noahpinion.blog/feed", "https://www.numlock.com/feed", "https://ryanmcbeth.substack.com/feed", "https://www.nycsouthpaw.com/feed", "https://www.persuasion.community/feed", "https://politickingetc.substack.com/feed", "https://popular.info/feed", "https://populism.substack.com/feed", "https://www.programmablemutter.com/feed", "https://www.readoptional.com/feed", "https://www.natesilver.net/feed", "https://www.slowboring.com/feed", "https://stevelichtenstein.substack.com/feed", "https://superbowl.substack.com/feed", "https://www.sustainabilitybynumbers.com/feed", "https://snyder.substack.com/feed", "https://daniellekurtzleben.substack.com/feed", "https://transmissionsfromtheredplanet.substack.com/feed", "https://smotus.substack.com/feed", "https://radleybalko.substack.com/feed", "https://williamfleitch.substack.com/feed", "https://wordswithyenhan.substack.com/feed"]
#non_substacks = ["https://acoup.blog/feed", "https://crookedtimber.org/feed/", "http://feeds.feedburner.com/MLBTRTransactions", "https://statmodeling.stat.columbia.edu/feed/", "https://kill-the-newsletter.com/feeds/lt36fwdlv0f0bnbj.xml", "https://stratechery.passport.online/feed/rss/AXqhHmNvk3poy5AdFVdD19", "https://www.science.org/digital-feed/pipeline"]
#stacks = Substacks + non_substacks
#print(stacks)
def resolve_entries(obj, info):
    # urls = mongo.aggregate(url_pipeline)
    # feed_dicts = [parser.construct_feed_dict(i['url']) for i in urls]
    # mongo.add_feeds(feed_dicts)
    try:
        entries = mongo.aggregate(pipeline2)
        real_entries = []
        for i in entries:
            entry = {
                "id": i["_id"],
                "pub_name": i['publication_name'],
                "title": i["title"],
                "is_content": False,
                "pub_date": i['date'],
                "text": i['value'],
                "url": i['link'],
                "pub_url": i['url'],
                "author": i['author']
            }
            real_entries.append(entry)
        #todos = [todo.to_dict() for todo in TodoItem.query.all()]
        payload = {
            "success": True,
            "entries": real_entries
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload


def resolve_pub_entries(obj, info, url):
    try:
        entries = mongo.aggregate(pub_pipeline(url))
        real_entries = []
        for i in entries:
            entry = {
                "id": i["_id"],
                "pub_name": i['publication_name'],
                "title": i["title"],
                "is_content": False,
                "pub_date": i['date'],
                "text": i['value'],
                "url": i['link'],
                "pub_url": i['url'],
                "author": i['author']
            }
            real_entries.append(entry)
        #todos = [todo.to_dict() for todo in TodoItem.query.all()]
        payload = {
            "success": True,
            "entries": real_entries
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload



@convert_kwargs_to_snake_case
def resolve_create_entry(obj, info, url):
    try:
        blog = parser.construct_feed_dict(url)
        mongo.add_feed(blog)
        payload = {
            "success": True,
            "entries": blog
        }
    except:
        payload = {
            "success": False,
            "errors": "Unknown Error"
        }

    return payload


# @convert_kwargs_to_snake_case
# def resolve_entry(obj, info, todo_id):
#     try:
#         todo = TodoItem.query.get(todo_id)
#         payload = {
#             "success": True,
#             "todo": todo.to_dict()
#         }

#     except AttributeError:  # todo not found
#         payload = {
#             "success": False,
#             "errors": [f"Todo item matching id {todo_id} not found"]
#         }

#     return payload

query = ObjectType("Query")

query.set_field("entries", resolve_entries)
query.set_field("pub_entries", resolve_pub_entries)

mutation = ObjectType("Mutation")

mutation.set_field("createBlogEntry", resolve_create_entry)

type_defs = load_schema_from_path("schema.graphql")
schema = make_executable_schema(
    type_defs, query, mutation, snake_case_fallback_resolvers
)

#query.set_field("todo", resolve_todo)

@app.route("/graphql", methods=["POST"])
def graphql_server():
    data = request.get_json()
    #print(data)
    success, result = graphql_sync(
        schema,
        data,
        context_value=request,
        debug=app.debug
    )
    print(success,result)# doesn't seem to be the thing printing
    status_code = 200 if success else 400
    return jsonify(result), status_code



if __name__ == '__main__':
    app.run(debug=True)
