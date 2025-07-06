import jwt
from ariadne import convert_kwargs_to_snake_case
import mongo
from pipelines import feed_and_url_pipeline, feed_url_pipeline, leaderboard_pipeline

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