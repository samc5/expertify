import mongo
import jwt
from dotenv import load_dotenv
import os
load_dotenv()
secret_key = os.getenv("SECRET")

def resolve_get_email(obj, info, token):
    try:
        received = jwt.decode(token, secret_key, algorithms=["HS256"])
        user_id = received['id']
        email = mongo.get_email(user_id)
        payload = {
            "success": True,
            "email": email
        }
    except Exception as error:
        payload = {
            "success": False,
            "errors": [str(error)]
        }
    return payload

def resolve_sign_up(obj, info, email, password):
    try:
        hash = mongo.hash(password)
        result = mongo.signUp(email,hash)
        if result[0]:
            payload = {
                "errors": "No errors, successful sign in"
            }
        elif result[1] == "Email already used":
            payload = {
                "errors": "Email is already in database - Please log in or use a different email"
            }
    except:
        payload = {
            "errors": "unknown errors"
        }
