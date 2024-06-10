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
          title: Text("Sign In"), // Set your desired app bar title
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
      url = Uri.parse('http://172.191.246.38:5000/login'); // URL for web
      //url = Uri.parse('http://localhost:5000/login'); // URL for web
    } else {
      if (Platform.isAndroid) {
        url =
            Uri.parse('http://10.0.2.2:5000/login'); // URL for Android emulator
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
      // Request successful, do something
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse['token']);
      if (jsonResponse['token'] != null) {
        return jsonResponse['token'];
      }
      print("reached second if thing");
      return "Failure";
    } else {
      // Request failed, handle error
      print('Error: ${response.reasonPhrase}');
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
                          final Future<String> loginResult =
                              submitForm(context);
                          String loginResult2 = await loginResult;
                          if (loginResult2 == "Failure") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Incorrect email or password'),
                                duration:
                                    Duration(seconds: 2), // Adjust as needed
                              ),
                            );
                          } else {
                            await deleteToken();
                            await storeToken(loginResult2);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavigationBarController()));
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
    );
  }
}
