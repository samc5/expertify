import 'package:flutter/material.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  static const routeName = '/add_feed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("Add a Feed"), // Set your desired app bar title
        ),
        body: DiscoveryForm());
  }
}

class DiscoveryForm extends StatefulWidget {
  const DiscoveryForm({super.key});

  @override
  DiscoveryFormState createState() {
    return DiscoveryFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class DiscoveryFormState extends State<DiscoveryForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<NewFeedFormState>.
  final _formKey = GlobalKey<FormState>();
  final UrlValue = TextEditingController();
  final TextEditingController categoryValue = TextEditingController();
  String? categorySelected;

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
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextField(
              // The validator receives the text that the user has entered.
              controller: UrlValue,
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter some text';
              //   }
              //   return value;
              // },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  // Solid border
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                hintText: 'Enter RSS Feed URL',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
            ),
          ],
        ),
      ),
    );
  }
}
