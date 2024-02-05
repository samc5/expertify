import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String newEntry = """
mutation newEntry(\$url: String!) {
  createBlogEntry(url: \$url) {
    success
    errors
    entries {
        url
        title
    }
  }
}
""";

class AddFeedScreen extends StatelessWidget {
  const AddFeedScreen({Key? key}) : super(key: key);

  static const routeName = '/add_feed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Add a Feed"), // Set your desired app bar title
        ),
        body: NewFeedForm());
  }
}

class NewFeedForm extends StatefulWidget {
  const NewFeedForm({super.key});

  @override
  NewFeedFormState createState() {
    return NewFeedFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class NewFeedFormState extends State<NewFeedForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<NewFeedFormState>.
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
                border: InputBorder.none,
                hintText: 'Enter RSS Feed URL',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
            ),
            // Add TextFormFields and ElevatedButton here.
            Mutation(
              options: MutationOptions(document: gql(newEntry)),
              builder: (runMutation, result) {
                return ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      runMutation({'url': UrlValue.text});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
