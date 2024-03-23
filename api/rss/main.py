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
#from flask_talisman import Talisman
load_dotenv()
secret_key = os.getenv("SECRET")

app = Flask(__name__)
#Talisman(app)
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


def personal_pipeline(url_list):
    return [
    {"$match": {"url": {"$in": url_list}}},
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
        print("payload loaded success")
    except Exception as e:
        print(e)
        payload = {
            "success": False,
            "errors": [str(e)]
        }
        print("payload loaded as a failure")
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

def resolve_category_entries(obj, info, token, category):
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

def resolve_categories_request(obj, info, token):
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
query.set_field("personal_entries", resolve_personal_entries)
query.set_field("category_entries", resolve_category_entries)
query.set_field("user", resolve_user_query)
query.set_field("fetch_categories", resolve_categories_request)
mutation = ObjectType("Mutation")

mutation.set_field("createBlogEntry", resolve_create_entry)
mutation.set_field("createPersonalEntry", resolve_create_personal_entry)
mutation.set_field("createCategoryEntry", resolve_create_category_entry)

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
    print(request.form)
    email = request.form['email']
    try:
        #pw_hash = mongo.hash(request.form['password'])
        #print(pw_hash)
        result = mongo.check_login(email, request.form['password'])
        if result and result != "No Match":
            user_id = str(result)
            payload = {
                'id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            return jsonify({'message': 'User authenticated successfully', 'token': token})
        else:
            print(result)
            return jsonify({'message': 'Registration Failed due to user not found', 'result': result}) 
    except Exception as e:
        print(e)
        return jsonify({'message': 'Registration Failed due to unknwon error'})


@app.route("/signup", methods=["POST"])
def signup():
    print('uhh')
    email = request.form['email']
    try:
        pw_hash = mongo.hash(request.form['password'])
        result = mongo.signUp(email,pw_hash)
        print(result)
        if result:
            user_id = str(result)
            payload = {
                'id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            return jsonify({'message': 'User registered successfully', 'token': token})
        else:
            return jsonify({'message': 'Registration Failed (likely email was in system)'})
    except Exception as e:
        print(e)
        return jsonify({'message': 'Registration Failed due to unknwon error'})

if __name__ == '__main__':
    app.run(debug=True) ## TODOOO ssl_context should be replaced with a real SSL immediately when this is hosted
