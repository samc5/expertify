from flask import Flask, request, jsonify
import os
from ariadne import load_schema_from_path, make_executable_schema, \
    graphql_sync, snake_case_fallback_resolvers, ObjectType
#from ariadne.constants import PLAYGROUND_HTML

from ariadne import convert_kwargs_to_snake_case
import mongo
import parser
import jwt
import datetime
from dotenv import load_dotenv
from flask_cors import CORS
#from flask_talisman import Talisman
load_dotenv()
secret_key = os.getenv("SECRET")

app = Flask(__name__)
# CORS(app, resources={
#     r"/graphql": {"origins": "*"},
#     r"/login": {"origins": "*"},
#     r"/signup": {"origins": "*"}
# })
app.app_context().push()
basedir = os.path.abspath(os.path.dirname(__file__))



# @app.after_request
# def after_request(response):
#   response.headers.add('Access-Control-Allow-Origin', '*')
#   response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
#   response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
#   return response

pipeline2 = [
    
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "description": 1,
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
            "description": 1,
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
    {"$limit": 100}
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
            "description": 1,
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
            "description": 1,
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
    {"$limit": 100}
]


def personal_pipeline(url_list):
    return [
    {"$match": {"url": {"$in": url_list}}},
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "description": 1,
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
            "description": 1,
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
    {"$limit": 100}
]

feed_and_url_pipeline = [
    {
        "$project": {
            "_id": 0,
            "title": 1,
            "url": 1,
            "description": 1
        }
    }
]

leaderboard_pipeline = [
    {"$sort": {"subscribers_count": -1}},  # Sort by subscribers_count in descending order
    {"$limit": 5},  # Limit to top 5
    {"$project": {
        "_id": 0,
        "description": 1,
        "title": 1,
        "url": 1
    }
    }
]

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
                "description": i['description'],
                "is_content": False,
                "pub_date": i['date'],
                "text": i['value'],
                "url": i['link'],
                "pub_url": i['url'],
                "author": i['author']
            }
            real_entries.append(entry)
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

def resolve_personal_entries(obj, info, token):
    print("resolving personal entries")
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        print("id computed")
        urls = mongo.get_user_feeds(user_id)
        print(urls)
        entries = mongo.aggregate(personal_pipeline(urls))
        print("entries acquired")
        real_entries = []
        for i in entries:
            entry = {
                "id": i["_id"],
                "pub_name": i['publication_name'],
                "title": i["title"],
                "description": i["description"],
                "is_content": False,
                "pub_date": humanize_date(i['date']),
                "text": i['value'],
                "url": i['link'],
                "pub_url": i['url'],
                "author": i['author']
            }
            real_entries.append(entry)
        payload = {
            "success": True,
            "entries": real_entries
        }
        print("payload loaded success")
    except Exception as e:
        print(e)
        payload = {
            "success": False,
            "errors": [str(e)]
        }
        print("payload loaded as a failure")
    return payload

def resolve_saved_entries(obj, info, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        bookmarked = mongo.fetch_user_bookmarks(user_id)
        payload = {
            "success": True,
            "entries": bookmarked
        }
    except Exception as e:
        payload = {
            "success": False,
            "errors": [str(e)]
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
                "description": i["description"],
                "is_content": False,
                "pub_date": humanize_date(i['date']),
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

def humanize_date(date_str):
    #2024-05-13 13:12:56
    date_format = "%Y-%m-%d %H:%M:%S"
    try:
        datetime_object = datetime.datetime.strptime(str(date_str), date_format)
        now = datetime.datetime.now()
        if datetime_object.date() == now.date():
            formatted_date = datetime_object.strftime('%I:%M %p')
        elif datetime_object.year < now.year:
            formatted_date = datetime_object.strftime('%m/%d/%y')
        else:
            formatted_date = datetime_object.strftime('%b %d')

        return formatted_date
    except Exception as error:
        print(error)
        return "Unknown Date"


def resolve_category_entries(obj, info, token, category):
 #   print("Python resolving category entries")
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        urls = mongo.get_user_category_links(user_id, category)
        entries = mongo.aggregate(personal_pipeline(list(urls)))
        real_entries = []
        for i in entries:
            entry = {
                "id": i["_id"],
                "pub_name": i['publication_name'],
                "title": i["title"],
                "description": i['description'],
                "is_content": False,
                "pub_date": humanize_date(i['date']),
                "text": i['value'],
                "url": i['link'],
                "pub_url": i['url'],
                "author": i['author']
            }
            real_entries.append(entry)
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
   

def resolve_categories_request(obj, info, token):
  #  print("Python resolving user categories request")
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        categories = mongo.get_user_categories(user_id)
       # print(categories)
        payload = {
            "success": True,
            "categories": categories
            }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload

def resolve_all_feeds(obj, info):
    try:
        feeds = mongo.aggregate(feed_and_url_pipeline)
        return feeds
        
    except Exception as error:
        print(str(error))

def resolve_check_feed(obj, info, url, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        result = mongo.check_user_feed(user_id, url)
        payload = {
            "result": result,
            "success": True,
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload

def resolve_fetch_leaderboard(obj, info):
    try:
        feeds = mongo.aggregate(leaderboard_pipeline)
        payload = {
            "success": True,
            "feeds": feeds
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(Error)]
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

def resolve_create_personal_entry(obj, info, url, token):
    try:
        blog = parser.construct_feed_dict(url)
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        mongo.add_user_link(user_id, blog)
        payload = {
            "success": True,
            "entries": blog
        }
    except:
        payload = {
            "success": False,
            "errors": "Unknown error"
        }
    return payload

def resolve_create_category_entry(obj, info, url, token, category):
    try:
        print("resolving create cateogy rnetyr")
        print(f'category: {category}')
        blog = parser.construct_feed_dict(url)
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        if category is None or category == "":
            mongo.add_user_link(user_id, blog)
        else:
            mongo.add_user_category_link(user_id, blog, category)
        payload = {
            "success": True,
            "entries": blog
        }
    except:
        payload = {
            "success": False,
            "errors": "Unknown error"
        }
    return payload
    
def resolve_create_categories_entry(obj, info, url, token, categories):
    try:
        print(f"creating categories entry for {url}")
        blog = parser.construct_feed_dict(url)  
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        if len(categories) == 0:
            mongo.add_user_link(user_id, blog)
        else:
            mongo.add_user_categories_link(user_id, blog, categories)
        payload = {
            "success": True,
            "entries": blog
        }
    except:
        payload = {
            "success": False,
            "errors": "Unknown error"
        }
    return payload

def resolve_delete_entry(obj, info, url, token):
    try: 
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        mongo.delete_user_link(user_id, url)
        payload = {
            "success": True,
        }
    except:
        payload = {
            "success": False,
            "errors": "deleting entry failure"
        }
    return payload

def resolve_bulk_entry(obj, info, bulkString):
    try: 
        feed_dicts = [parser.construct_feed_dict(i) for i in bulkString.split('\n')]
        mongo.add_feeds(feed_dicts)
        real_entries = []
        for feed in feed_dicts:
            real_entries.append({
                    "url": feed['url'],
                    "title": feed['title']
                })
        payload = {
             "entries": real_entries,
            "success": True
            }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }

    return payload

def resolve_user_query(obj, info, email, password):
    try:
        user = mongo.check_user({"email": email, "password": password})
        user_dict = {
            'id': user['_id'],
            'email': user['email'],
            'password': user['password']
        }
        if user:
            print(user)
            payload = {
                "success": True,
                "user": user_dict
            }
        else:
            payload = {
                "success": False,
                "errors": "User not in DB"
            }
    except:
        payload = {
            "success": False,
            "errors": "Unknown Error"
        }
    return payload

def resolve_save_article(obj, info, article, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        mongo.save_personal(article, user_id)
        payload = {
            "success": True,
            "url": article['url']
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)],
        }
    return payload

def resolve_sign_up(obj, info, email, password):
    # TODO add hashing and put it into the mongo database
    try:
        hash = mongo.hash(password)
        result = mongo.signUp(email,hash)
        if result[0]:
            payload = {
                "errors": "No errors, successful sign in"
            }
        elif result[1] == "Email already used":
            payload = {
            #     "errors": "error"
                "errors": "Email is already in database - Please log in or use a different email"
            }
    except:
        payload = {
            "errors": "unknown errors"
        }



query = ObjectType("Query")

query.set_field("entries", resolve_entries)
query.set_field("pub_entries", resolve_pub_entries)
query.set_field("personal_entries", resolve_personal_entries)
query.set_field("category_entries", resolve_category_entries)
query.set_field("user", resolve_user_query)
query.set_field("fetch_categories", resolve_categories_request)
query.set_field("allFeeds", resolve_all_feeds)
query.set_field("checkForFeed", resolve_check_feed)
query.set_field("fetchLeaderboard", resolve_fetch_leaderboard)
query.set_field("saved_entries", resolve_saved_entries)

mutation = ObjectType("Mutation")

mutation.set_field("createBlogEntry", resolve_create_entry)
mutation.set_field("createPersonalEntry", resolve_create_personal_entry)
mutation.set_field("createCategoryEntry", resolve_create_category_entry)
mutation.set_field("createCategoriesEntry", resolve_create_categories_entry)
mutation.set_field("deleteBlogEntry", resolve_delete_entry)
mutation.set_field("createBulkEntry", resolve_bulk_entry)
mutation.set_field("saveArticle", resolve_save_article)

mutation.set_field("signUp", resolve_sign_up)

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
    print(success) # ABSOLUTELY IS THE THING PRINTING
    status_code = 200 if success else 400
    return jsonify(result), status_code

@app.route("/login", methods=["POST"])
def login():
    email = request.form['email']
    try:
        result = mongo.check_login(email, request.form['password'])
        if result and result != "No Match":
            user_id = str(result)
            payload = {
                'id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=1) # JWT lasts one week, so users should only have to sign in that often
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            return jsonify({'message': 'User authenticated successfully', 'token': token, 'result': result})
        else:
            return jsonify({'message': 'Registration Failed due to user not found', 'result': result}) 
    except Exception as e:
        print(e)
        return jsonify({'message': 'Registration Failed due to unknwon error', 'result': result})


@app.route("/signup", methods=["POST"])
def signup():
    #print('uhh')
    email = request.form['email']
    try:
        pw_hash = mongo.hash(request.form['password'])
        result = mongo.signUp(email,pw_hash)
        print(result)
        if result:
            user_id = str(result)
            payload = {
                'id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=1)
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            print("user registered successfully, token = " + token)
            return jsonify({'message': 'User registered successfully', 'token': token})
        else:
            print("registration failed probably emailw as in system")
            return jsonify({'message': 'Registration Failed (likely email was in system)'})
    except Exception as e:
        print(e)
        print("that was an unknwon error")
        return jsonify({'message': 'Registration Failed due to unknown error'})

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000) ## TODOOO ssl_context should be replaced with a real SSL immediately when this is hosted
