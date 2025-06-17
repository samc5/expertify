import mongo
import jwt
from pipelines import pipeline2, personal_pipeline, pub_pipeline
from dotenv import load_dotenv
import os
load_dotenv()
secret_key = os.getenv("SECRET")

def resolve_entries(obj, info):
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