import 'dart:developer';

import 'package:flutter/material.dart';
import 'navigation_bar_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON decoding
import 'signup_screen.dart';
import 'form_field.dart';
import 'token_operations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("Log In"), // Set your desired app bar title
        ),
        body: LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<LoginFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailValue = TextEditingController();
  final passwordValue = TextEditingController();
  String? token;
  bool isPressed = false;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailValue.dispose();
    passwordValue.dispose();
    super.dispose();
  }

  void initState() {
    _fetchToken();
  }

  Future<String> submitForm(BuildContext context) async {
    // Extracting email and password from text controllers
    String email = emailValue.text;
    String password = passwordValue.text;

    var url;
    if (kIsWeb) {
      //url = Uri.parse('https://samcowan.net/login'); // URL for web
      url = Uri.parse('http://localhost:5000/login'); // URL for web
    } else {
      if (Platform.isAndroid) {
        url =
            Uri.parse('https://samcowan.net/login'); // URL for Android emulator
      } else if (Platform.isWindows) {
        url = Uri.parse('http://localhost:5000/login'); // URL for Windows app
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
      log("response successful block");
      // Request successful, do something
      Map<String, dynamic> jsonResponse =
          json.decode(response.body); // it at least gets here
      log(jsonResponse.toString());
      if (jsonResponse['token'] != null) {
        print("return jsonResponse");
        return jsonResponse['token'];
      }
      log("reached second if thing");
      return "Failure";
    } else {
      // Request failed, handle error
      log('Error: ${response.reasonPhrase}');
      return "Failure";
    }
  }

  void login() async {
    log("at the top of login");
    if (_formKey.currentState!.validate()) {
      // Process form data
      final Future<String> loginResult = submitForm(context);
      String loginResult2 = await loginResult;
      log(loginResult2);
      if (loginResult2 == "Failure") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect email or password'),
            duration: Duration(seconds: 2), // Adjust as needed
          ),
        );
      } else {
        if (kIsWeb) {
          deleteWebToken();
        } else {
          await deleteToken();
        }
        await deleteAllStorage();
        if (kIsWeb) {
          storeWebToken(loginResult2);
        } else {
          await storeToken(loginResult2);
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationBarController()));
      }
    }
  }

  Future<void> _fetchToken() async {
    try {
      if (kIsWeb) {
        final _token = await getWebToken();
        setState(() {
          token = _token;
        });
      } else {
        final _token = await getToken();
        setState(() {
          token = _token;
        });
      }
      if (token != null) {
        print('token: ' + token.toString());
        if (await verifyToken(token!)) {
          _navigateToHome();
        }
      }
    } catch (e) {
      print("Error fetching token: $e");
      // Handle error appropriately, like showing an error message
    }
    // setState(() {}); // Trigger a rebuild after token is fetched
  }

  void _navigateToHome() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BottomNavigationBarController()));
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    //_fetchToken();
    // if (token != null) {
    //   Future.delayed(Duration(milliseconds: 1), () {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => BottomNavigationBarController()));
    //   });
    // }
    return Padding(
      padding:
          const EdgeInsets.only(top: 100, bottom: 100, right: 20, left: 20),
      child: Center(
        child: SingleChildScrollView(
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
                        formLabel: "Email",
                        password: false,
                        onFieldSubmitted: login),
                    SizedBox(
                        height:
                            20), // Add space between text field and other widgets
                    LogFormField(
                        textValue: passwordValue,
                        formLabel: "Password",
                        password: true,
                        onFieldSubmitted: login),

                    Padding(padding: EdgeInsets.only(bottom: 25)),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPressed = true;
                          });
                          //print("login button pressed");

                          login();
                          Future.delayed(Duration(milliseconds: 800), () {
                            setState(() {
                              isPressed = false;
                            });
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: isPressed
                              ? MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 119, 167, 206))
                              : MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 11, 88, 151)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          ),
                        ),
                        child: Text('Log In',
                            style: TextStyle(color: Colors.white)),
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
                                  builder: (context) => SignUpScreen()));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 140, 35, 6)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          ),
                        ),
                        child: Text('Sign Up Instead',
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
      ),
    );
  }
}
