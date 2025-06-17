import mongo
import parser
import jwt
from ariadne import convert_kwargs_to_snake_case

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
        bozos = []
        filtered_dicts = []
        for feed in feed_dicts:
            if feed['bozo'] == 1:
                bozos.append(feed['url'])
            else:
                filtered_dicts.append(feed)
        mongo.add_feeds(filtered_dicts)
        real_entries = []
        for feed in filtered_dicts:
            real_entries.append({
                    "url": feed['url'],
                    "title": feed['title']
                })
        if len(bozos) == 0:
            payload = {
                "entries": real_entries,
                "success": True
                }
        else:
            payload = {
                "entries": real_entries,
                "success": True,
                "bozos": bozos
                }            
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }

    return payload