import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> storeToken(String jwtToken) async {
  // ChatGPT written
  final storage = FlutterSecureStorage();
  await storage.write(key: 'jwt_token', value: jwtToken);
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
