import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String feeds_query = """
query fetchAllFeeds {
  allFeeds {
    title
    url
  }
}
""";

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
        child: Center(
          child: Query(
            options: QueryOptions(document: gql(feeds_query)),
            builder: (result, {fetchMore, refetch}) {
              return SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(
                    5,
                    (int index) {
                      final String item = 'item $index';
                      return ListTile(
                        title: Text(item),
                        trailing: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(
                                0xFF511730), // Use Color(0xFF511730) for the color #511730
                          ),
                          child: Center(
                            child: IconButton(
                              iconSize: 20,
                              icon: Icon(Icons.add,
                                  color: Colors
                                      .white), // Ensure the icon color contrasts well with the background
                              onPressed: () {
                                // Add your onPressed logic here
                              },
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            controller.closeView(item);
                          });
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ));
  }
}
