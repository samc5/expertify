import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'token_operations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Settings"), // Set your desired app bar title
        ),
        body: SettingsForm());
  }
}

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SettingsFormState extends State<SettingsForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<SettingsFormState>.
  final _formKey = GlobalKey<FormState>();
  final UrlValue = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    UrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: ElevatedButton(
              child: Text("Log Out"),
              onPressed: () {
                if (kIsWeb) {
                  deleteWebToken();
                } else {
                  deleteToken();
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
        ));
  }
}
