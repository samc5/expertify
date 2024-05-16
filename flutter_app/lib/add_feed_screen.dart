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

class AddFeedScreen extends StatelessWidget {
  const AddFeedScreen({Key? key}) : super(key: key);

  static const routeName = '/add_feed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
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
            DropdownMenu<String>(
              width: 200,
              controller: categoryValue,
              enableFilter: true,
              requestFocusOnTap: true,
              leadingIcon: const Icon(Icons.search),
              label: const Text('Category'),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5.0),
              ),
              onSelected: (String? category) {
                setState(() {
                  categorySelected = category;
                });
              },
              dropdownMenuEntries: [
                DropdownMenuEntry<String>(
                  value: 'Panopticon',
                  label: 'Panopticon',
                ),
                DropdownMenuEntry<String>(
                  value: 'Substacks',
                  label: 'Substacks',
                ),
                DropdownMenuEntry<String>(
                  value: 'Sports',
                  label: 'Sports',
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            Mutation(
              options: MutationOptions(document: gql(newerEntry)),
              builder: (runMutation, result) {
                return ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      final token = await getToken();
                      // If the form is valid, display a snackbar
                      runMutation({
                        'url': UrlValue.text,
                        'token': token,
                        'category': categoryValue.text
                      });
                      UrlValue.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Submitted'),
                          duration: Duration(seconds: 1), // Adjust as needed
                        ),
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

// DropdownMenuEntry labels and values for the first dropdown menu.

// DropdownMenuEntry labels and values for the second dropdown menu.
enum IconLabel {
  smile('Smile', Icons.sentiment_satisfied_outlined),
  cloud(
    'Cloud',
    Icons.cloud_outlined,
  ),
  brush('Brush', Icons.brush_outlined),
  heart('Heart', Icons.favorite);

  const IconLabel(this.label, this.icon);
  final String label;
  final IconData icon;
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  final TextEditingController iconController = TextEditingController();
  IconLabel? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 24),
                    DropdownMenu<IconLabel>(
                      controller: iconController,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      leadingIcon: const Icon(Icons.search),
                      label: const Text('Icon'),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (IconLabel? icon) {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                      dropdownMenuEntries:
                          IconLabel.values.map<DropdownMenuEntry<IconLabel>>(
                        (IconLabel icon) {
                          return DropdownMenuEntry<IconLabel>(
                            value: icon,
                            label: icon.label,
                            leadingIcon: Icon(icon.icon),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              if (selectedIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('You selected a ${selectedIcon?.label}'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        selectedIcon?.icon,
                        color: Colors.blueGrey,
                      ),
                    )
                  ],
                )
              else
                const Text('Please select a color and an icon.')
            ],
          ),
        ),
      ),
    );
  }
}
