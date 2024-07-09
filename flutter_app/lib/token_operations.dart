import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void storeWebToken(String token) {
  html.window.localStorage['jwt_token'] = token;
}

Future<String?> getWebToken() async {
  return await html.window.localStorage['jwt_token'];
}

void deleteWebToken() {
  html.window.localStorage.remove('jwt_token');
}

Future<void> storeToken(String jwtToken) async {
  // ChatGPT written
  final storage = FlutterSecureStorage();
  try {
    await storage.write(key: 'jwt_token', value: jwtToken);
    log('Token stored successfully');
  } catch (e) {
    log('Error storing token: $e');
  }
}

Future<String?> getToken() async {
  //ChatGPT written
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'jwt_token');
}

Future<void> deleteToken() async {
  // chatgpt written
  final storage = FlutterSecureStorage();
  await storage.delete(key: 'jwt_token');
}

Future<void> deleteAllExcept(String keyToKeep) async {
  // Get all keys
  final storage = FlutterSecureStorage();
  Map<String, String> allValues = await storage.readAll();

  // Iterate over all keys and delete each one except the key to keep
  for (String key in allValues.keys) {
    if (key != keyToKeep) {
      await storage.delete(key: key);
    }
  }
}

Future<void> deleteAllStorage() async {
  final storage = FlutterSecureStorage();
  await storage.deleteAll();
}

Future<bool> verifyToken(String token) async {
  //await dotenv.load(fileName: ".env");
  try {
    final jwt = JWT.verify(token, SecretKey(dotenv.env['SECRET']!));
    return true;
    //print('Payload: ${jwt.payload}');
  } on JWTExpiredException {
    return false;
    //print('JWT expired');
  } on JWTException catch (ex) {
    return false;
    //print('Error: $ex');
  }
}
