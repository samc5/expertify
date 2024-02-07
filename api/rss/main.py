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
    print(data)
    success, result = graphql_sync(
        schema,
        data,
        context_value=request,
        debug=app.debug
    )
    print(success,result)
    status_code = 200 if success else 400
    return jsonify(result), status_code



if __name__ == '__main__':
    app.run(debug=True)
