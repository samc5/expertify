import 'dart:developer';

import 'package:flutter/material.dart';
import 'navigation_bar_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON decoding
import 'login_screen.dart';
import 'form_field.dart';
import 'token_operations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("Create an Account"), // Set your desired app bar title
        ),
        body: SignUpForm());
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  SignUpFormState createState() {
    return SignUpFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignUpFormState extends State<SignUpForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<SignUpFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailValue = TextEditingController();
  final passwordValue = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailValue.dispose();
    passwordValue.dispose();
    super.dispose();
  }

  Future<String> submitForm(BuildContext context) async {
    // Extracting email and password from text controllers
    String email = emailValue.text;
    String password = passwordValue.text;
    var url;
    if (kIsWeb) {
      url = Uri.parse('http://172.191.246.38:5000/signup'); // URL for web
    } else {
      if (Platform.isAndroid) {
        url = Uri.parse(
            'http://10.0.2.2:5000/signup'); // URL for Android emulator
      } else if (Platform.isWindows) {
        url = Uri.parse(
            'http://172.191.246.38:5000/signup'); // URL for Windows app
      }
    }
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      // Request successful, do something
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      log(jsonResponse['token']);
      if (jsonResponse['token'] != null) {
        return jsonResponse['token'];
      }
      log("the thing is null");
      if (jsonResponse['message'] ==
          "Registration Failed (likely email was in system)") {
        return "User in System";
      }
      return "Failure";
    } else {
      // Request failed, handle error
      log('Error: ${response.reasonPhrase}');
      return "Failure";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Padding(
      padding:
          const EdgeInsets.only(top: 100, bottom: 100, right: 20, left: 20),
      child: Center(
        child: Container(
          width: 1000,
          padding: EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //     border: Border.all(
          //   color: Colors.black, // Add your desired border color here
          //   width: 2.0,
          // )),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  LogFormField(
                      textValue: emailValue,
                      formLabel: "Enter Your Email",
                      password: false),
                  SizedBox(
                      height:
                          20), // Add space between text field and other widgets
                  LogFormField(
                      textValue: passwordValue,
                      formLabel: "Enter Your Password",
                      password: true),
                  Padding(padding: EdgeInsets.only(bottom: 25)),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Process form data
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(emailValue.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Email invalid. Please enter a valid format'),
                                duration:
                                    Duration(seconds: 2), // Adjust as needed
                              ),
                            );
                          } else {
                            final Future<String> SignUpResult =
                                submitForm(context);
                            String SignUpResult2 = await SignUpResult;
                            if (SignUpResult2 == "Failure") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unknwown Failure'),
                                  duration:
                                      Duration(seconds: 2), // Adjust as needed
                                ),
                              );
                            } else if (SignUpResult2 == "User in System") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Email is already used. Please log in or try a different email'),
                                  duration:
                                      Duration(seconds: 2), // Adjust as needed
                                ),
                              );
                            } else {
                              await deleteToken();
                              await storeToken(SignUpResult2);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BottomNavigationBarController()));
                            }
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 11, 88, 151)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                      ),
                      child:
                          Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 2, 69, 8)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                      ),
                      child: Text('Log in instead',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
