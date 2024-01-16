from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os
from ariadne import load_schema_from_path, make_executable_schema, \
    graphql_sync, snake_case_fallback_resolvers, ObjectType
#from ariadne.constants import PLAYGROUND_HTML

from ariadne import convert_kwargs_to_snake_case


app = Flask(__name__)
app.app_context().push()
basedir = os.path.abspath(os.path.dirname(__file__))

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'db.sqlite')


# suppress SQLALCHEMY_TRACK_MODIFICATIONS warning
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
ma = Marshmallow(app)


class TodoItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    is_executed = db.Column(db.Boolean)

    def __init__(self, name, is_executed):
        self.name = name
        self.is_executed = is_executed
    
    def to_dict(self):
        return {
            "id": self.id,
            "is_executed": self.is_executed,
            "name": self.name
        }


# Todo schema
class TodoSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'is_executed')


# Initialize schema
todo_schema = TodoSchema()
todos_schema = TodoSchema(many=True)



def resolve_todos(obj, info):
    try:
        todos = [todo.to_dict() for todo in TodoItem.query.all()]
        payload = {
            "success": True,
            "todos": todos
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload

@convert_kwargs_to_snake_case
def resolve_todo(obj, info, todo_id):
    try:
        todo = TodoItem.query.get(todo_id)
        payload = {
            "success": True,
            "todo": todo.to_dict()
        }

    except AttributeError:  # todo not found
        payload = {
            "success": False,
            "errors": [f"Todo item matching id {todo_id} not found"]
        }

    return payload

@convert_kwargs_to_snake_case
def resolve_create_todo(obj, info, name):
    try:
        todo = TodoItem(name, False)
        db.session.add(todo)
        db.session.commit()
        payload = {
            "success": True,
            "todo": todo.to_dict()
        }
    except:
        payload = {
            "success": False,
            "errors": "Unknown Error"
        }

    return payload


@convert_kwargs_to_snake_case
def resolve_mark_done(obj, info, todo_id):
    try:
        todo = TodoItem.query.get(todo_id)
        todo.is_executed = not todo.is_executed
        db.session.add(todo)
        db.session.commit()
        payload = {
            "success": True,
            "todo": todo.to_dict()
        }
    except AttributeError:  # todo not found
        payload = {
            "success": False,
            "errors":  [f"Todo matching id {todo_id} was not found"]
        }

    return payload

@convert_kwargs_to_snake_case
def resolve_delete_todo(obj, info, todo_id):
    try:
        todo = TodoItem.query.get(todo_id)
        db.session.delete(todo)
        db.session.commit()
        payload = {"success": True}

    except AttributeError:
        payload = {
            "success": False,
            "errors": [f"Todo matching id {todo_id} not found"]
        }

    return payload



query = ObjectType("Query")

query.set_field("todos", resolve_todos)
query.set_field("todo", resolve_todo)


mutation = ObjectType("Mutation")
mutation.set_field("createTodo", resolve_create_todo)
mutation.set_field("markDone", resolve_mark_done)
mutation.set_field("deleteTodo", resolve_delete_todo)

type_defs = load_schema_from_path("schema.graphql")
schema = make_executable_schema(
    type_defs, query, mutation, snake_case_fallback_resolvers
)

@app.route('/todo', methods=['POST'])
def add_todo():
    print(request.json)
    name = request.json['name']
    is_executed = request.json['is_executed']

    new_todo_item = TodoItem(name, is_executed)
    db.session.add(new_todo_item)
    db.session.commit()

    return todo_schema.jsonify(new_todo_item)


@app.route('/todo', methods=['GET'])
def get_todos():
    all_todos = TodoItem.query.all()
    result = todos_schema.dump(all_todos)

    return jsonify(result)

@app.route('/todo/<id>', methods=['PUT', 'PATCH'])
def execute_todo(id):
    todo = TodoItem.query.get(id)

    todo.is_executed = not todo.is_executed
    db.session.commit()

    return todo_schema.jsonify(todo)

@app.route('/todo/<id>', methods=['DELETE'])
def delete_todo(id):
    todo_to_delete = TodoItem.query.get(id)
    db.session.delete(todo_to_delete)
    db.session.commit()

    return todo_schema.jsonify(todo_to_delete)

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




