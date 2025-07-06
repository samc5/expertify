from flask import Flask, request, jsonify
import os
from ariadne import load_schema_from_path, make_executable_schema, \
    graphql_sync, snake_case_fallback_resolvers, ObjectType, \
    convert_kwargs_to_snake_case
import mongo
import parser
import jwt
import datetime
from dotenv import load_dotenv
from flask_cors import CORS
from authresolve import resolve_get_email, resolve_sign_up
from entries import resolve_entries, resolve_pub_entries, \
    resolve_personal_entries, resolve_saved_entries, resolve_category_entries
from pipelines import feed_and_url_pipeline, feed_url_pipeline, \
    leaderboard_pipeline, personal_pipeline, feed_and_url_pipeline
from utils import humanize_date
from mutations import resolve_create_entry, resolve_create_personal_entry, \
    resolve_create_category_entry, resolve_create_categories_entry, \
    resolve_delete_entry, resolve_bulk_entry
load_dotenv()
secret_key = os.getenv("SECRET")

app = Flask(__name__)
app.app_context().push()
basedir = os.path.abspath(os.path.dirname(__file__))

def resolve_categories_request(obj, info, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        categories = mongo.get_user_categories(user_id)
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

def resolve_all_user_feeds(obj, info, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        urls = mongo.get_user_feeds(user_id)
        feeds = mongo.aggregate(feed_url_pipeline(urls))
        payload = {
            "success": True,
            "feeds": feeds
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload

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


def resolve_get_latest_time(obj, info):
    latest_time = mongo.time_last_crawl()
    if latest_time:
        print(latest_time)
        return {"timestamp": latest_time.isoformat() + 'Z'}
    else:
        return {"timestamp": None}
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
query.set_field("allUserFeeds", resolve_all_user_feeds)
query.set_field("get_email", resolve_get_email)
query.set_field("get_latest_time", resolve_get_latest_time)

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

@app.route("/graphql", methods=["POST"])
def graphql_server():
    data = request.get_json()
    success, result = graphql_sync(
        schema,
        data,
        context_value=request,
        debug=app.debug
    )
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
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
            }
            token = jwt.encode(payload, secret_key, algorithm='HS256')
            return jsonify({'message': 'User authenticated successfully', 'token': token})
        else:
            return jsonify({'message': 'Registration Failed due to user not found'}) 
    except Exception as e:
        print(e)
        return jsonify({'message': 'Registration Failed due to unknwon error'})


@app.route("/signup", methods=["POST"])
def signup():
    email = request.form['email']
    try:
        pw_hash = mongo.hash(request.form['password'])
        result = mongo.signUp(email,pw_hash)
        print(result)
        if result:
            user_id = str(result)
            payload = {
                'id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
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
