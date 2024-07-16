import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'token_operations.dart';

const String newerEntry = """
mutation newEntry(\$url: String!, \$token: String!, \$category: String!){
  createCategoryEntry(url: \$url, token: \$token, category: \$category) {
    success
    errors
    entries {
        url
        title
    }
  }
}
""";

const String newEntry = """
mutation newEntry(\$url: String!, \$token: String!) {
  createPersonalEntry(url: \$url, token: \$token) {
    success
    errors
    entries {
        url
        title
    }
  }
}
""";

const String oldnewEntry = """
mutation newEntry(\$url: String!) {
  createPersonalEntry(url: \$url) {
    success
    errors
    entries {
        url
        title
    }
  }
}
""";

const String bulkEntry = '''
mutation(\$bulkString: String!) {
  createBulkEntry(bulkString: \$bulkString) {
    entries {
     title
     url
    }
    bozos
    success
    errors
  }
}
''';

class AddFeedScreen extends StatelessWidget {
  const AddFeedScreen({Key? key}) : super(key: key);

  static const routeName = '/add_feed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // automaticallyImplyLeading: false,
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
  final bulkValue = TextEditingController();
  final TextEditingController categoryValue = TextEditingController();
  String? categorySelected;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    UrlValue.dispose();
    bulkValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: const Text(
                  "Enter RSS Feed URLs",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: const Text(
                  "Feeds will be added to Expertify's global database and made accessible by search to all users. To enter multiple feeds at once, each link must be on its own line (separated by the enter key)",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: TextField(
                  controller: bulkValue,
                  maxLines: null, // Allows for multiple lines
                  decoration: InputDecoration(
                    hintText: 'Enter your text here',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Mutation(
                options: MutationOptions(
                    document: gql(bulkEntry),
                    onCompleted: (dynamic resultData) {
                      //print(resultData);
                      List<dynamic>? bozos1 =
                          resultData['createBulkEntry']['bozos'];
                      if (bozos1 != null) {
                        // print(bozos1);
                        List<String> bozos =
                            (bozos1.map((e) => e as String)).toList();
                        String bozoString = bozos.join('\n');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'The following feeds are not parsable and likely broken:\n\n $bozoString\n\nIf you submitted other feeds, they have probably gone through successfully',
                                style: TextStyle(fontSize: 16.0)),
                            duration: Duration(seconds: 4), // Adjust as needed
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Feed(s) Submitted Successfully\n\nYou can now find them in the search feature'),
                            duration: Duration(seconds: 1), // Adjust as needed
                          ),
                        );
                      }
                    }),
                builder: (runMutation, result) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        runMutation({
                          'bulkString': bulkValue.text,
                        });
                        bulkValue.clear();
                      }
                    },
                    child: const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
