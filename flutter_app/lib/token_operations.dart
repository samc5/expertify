import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;

void storeWebToken(String token) {
  html.window.localStorage['jwt_token'] = token;
}

String? getWebToken() {
  return html.window.localStorage['jwt_token'];
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
