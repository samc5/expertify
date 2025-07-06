import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_screen.dart';

const String feeds_query = """
query fetchAllFeeds {
  allFeeds {
    title
    url
    description
  }
}
""";

const String leaderboard_query = """
query fetchLeaderboard{
  fetchLeaderboard {
    success
    errors
    feeds {
      title
      url
      description
    }
  }
}
""";

String getTitle(Map<String, dynamic> feed) {
  return feed['title']!;
}

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  static const routeName = '/discovery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("Discover New Sources"), // Set your desired app bar title
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
  final TextEditingController categoryValue = TextEditingController();
  String? categorySelected;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // UrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Query(
            options: QueryOptions(document: gql(feeds_query)),
            builder: (result, {fetchMore, refetch}) {
              if (result.hasException) {
                log(result.exception.toString());
                return const Center(
                  child: Text(
                      "There was an issue loading the content... please refresh the page or try again once you have internet connection"),
                );
              }
              if (result.data == null) {
                return Center(child: Text("loading"));
              }
              final feeds = result.data!['allFeeds'];
              return SearchAnchor(
                isFullScreen: false,
                viewConstraints: BoxConstraints(
                  minHeight: kToolbarHeight,
                  maxHeight: kToolbarHeight * 5,
                ),
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
                    hintText: "Search for Feeds",
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  List<Map<String, dynamic>> filteredFeeds = [];
                  final List<String> html_elements = [
                    "<title",
                    "<p",
                    "<h1",
                    "<div"
                  ];
                  // bool for is there an html element in the description
                  for (int i = 0; i < feeds.length; i++) {
                    if ((feeds[i]['title'] + feeds[i]['description'])
                        .toLowerCase()
                        .contains(controller.value.text.toLowerCase()) &&
                        !feeds[i]['description'].contains("<title") &&
                        !feeds[i]['description'].contains("<p") &&
                        !feeds[i]['description'].contains("<h1") &&
                        !feeds[i]['description'].contains("<div") &&
                        !feeds[i]['description'].contains("<script")
                        ){
                      filteredFeeds.add(feeds[i]);
                    }
                  }
                  filteredFeeds.sort((a, b) => getTitle(a).compareTo(getTitle(
                      b))); //  fruits.sort((a, b) => getPrice(a).compareTo(getPrice(b)));
                  return List<ListTile>.generate(
                    filteredFeeds.length,
                    (int index) {
                      final String item = filteredFeeds[index]['title'];
                      final String description =
                          filteredFeeds[index]['description'];
                      return ListTile(
                        title: Text(item),
                        subtitle: Text(description),
                        onTap: () {
                          setState(() {
                            //controller.closeView(item);
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PubArticlesWidget(
                                        url: filteredFeeds[index]['url'],
                                        pub_name: filteredFeeds[index]
                                            ['title'])));
                          });
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          Center(
            child: Text(
              "Most Popular Feeds",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Query(
              options: QueryOptions(document: gql(leaderboard_query)),
              builder: (result2, {fetchMore, refetch}) {
                if (result2.hasException) {
                  return Center(
                      child: Text(
                          "There was an issue loading the content... please refresh the page or try again once you have internet connection"));
                }

                if (result2.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                final List feeds =
                    result2.data?['fetchLeaderboard']['feeds'] ?? [];

                return feeds.isEmpty
                    ? Center(child: Text('No feeds available'))
                    : Expanded(
                        child: Center(
                          child: ListView.builder(
                            itemCount: feeds.length,
                            itemBuilder: (context, index) {
                              final feed = feeds[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PubArticlesWidget(
                                                  pub_name: feed['title'],
                                                  url: feed['url']))),
                                  child: Container(
                                    width:
                                        double.infinity, // Expand to full width
                                    decoration: BoxDecoration(
                                      color: Color(
                                          0xFF511730), // Change color as needed
                                      borderRadius: BorderRadius.circular(
                                          8), // Add rounded corners
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(
                                            feed['title'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Change text color as needed
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            feed['description'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Change text color as needed
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
              }),
        ],
      ),
    );
  }
}
