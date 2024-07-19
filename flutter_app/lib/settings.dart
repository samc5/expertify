import 'dart:developer';

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'token_operations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'custom_logos.dart';

const String user_feeds_query = """
query fetchAllFeeds(\$token: String!) {
  allUserFeeds(token: \$token) {
    success
    errors
    feeds {
      title
      url
    }
  }
}
""";

const String email_query = """
query fetchEmail(\$token: String!) {
  get_email(token: \$token) {
    success
    errors
    email
  }
}
""";

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
//  final _formKey = GlobalKey<FormState>();
  final UrlValue = TextEditingController();
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      if (kIsWeb) {
        token = await getWebToken();
      } else {
        token = await getToken();
      }
    } catch (e) {
      log("Error fetching token: $e");
      // Handle error appropriately, like showing an error message
    }
    setState(() {}); // Trigger a rebuild after token is fetched
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    UrlValue.dispose();
    super.dispose();
  }

  void _showFeedsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subscribed Feeds"),
          content: Query(
              options: QueryOptions(
                  document: gql(user_feeds_query),
                  variables: <String, dynamic>{"token": token!}),
              builder: (result, {fetchMore, refetch}) {
                if (result.hasException) {
                  log(result.exception.toString());
                  return const Center(
                    child: Text("Error occurred while fetching data!"),
                  );
                }
                if (result.data == null) {
                  return Center(
                    child: Text("Loading...", style: TextStyle(fontSize: 25)),
                  );
                }
                //return Center(child: Text("kind of worked"))
                final feeds = result.data!['allUserFeeds']['feeds'];
                return Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: feeds.length,
                    itemBuilder: (BuildContext context, int index) {
                      String feed_title = feeds[index]['title'];
                      String feed_url = feeds[index]['url'];
                      return Column(
                        children: [
                          ListTile(
                              title: Text(feed_title),
                              subtitle: Text(feed_url)),
                          Divider()
                        ],
                      );
                    },
                  ),
                );
              }),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            children: [
              Query(
                  options: QueryOptions(
                      document: gql(email_query),
                      variables: <String, dynamic>{"token": token}),
                  builder: (result, {fetchMore, refetch}) {
                    if (result.hasException) {
                      log(result.exception.toString());
                      return Container();
                    }
                    if (result.isLoading) {
                      return Container();
                    }
                    if (result.data == null) {
                      return Container();
                    }
                    final getEmailData = result.data!['get_email'];
                    if (getEmailData == null || getEmailData['email'] == null) {
                      return Container();
                    }
                    final email = getEmailData['email'];
                    return Center(
                        child: Text("You are $email",
                            style: TextStyle(fontSize: 20)));
                  }),
              Padding(padding: const EdgeInsets.only(top: 20)),
              SizedBox(
                width: 500,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      deleteWebToken();
                    } else {
                      await deleteToken();
                    }
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Color.fromARGB(255, 140, 35, 6)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                  ),
                  child: Text('Log Out', style: TextStyle(color: Colors.white)),
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 20)),
              // SizedBox(
              //     width: 500,
              //     height: 50,
              //     child: ElevatedButton(
              //       onPressed: () {},
              //       style: ButtonStyle(
              //         backgroundColor: WidgetStateProperty.all<Color>(
              //             Color.fromARGB(255, 140, 35, 6)),
              //         shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              //           RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(0.0),
              //           ),
              //         ),
              //       ),
              //       child: Text('Edit Categories',
              //           style: TextStyle(color: Colors.white)),
              //     )),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 20.0),
              // ),
              SizedBox(
                  width: 500,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showFeedsDialog,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromARGB(255, 140, 35, 6)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                    child: Text('View Subscribed Feeds',
                        style: TextStyle(color: Colors.white)),
                  )),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
              ),
              GithubLink()
            ],
          ),
        ));
  }
}
