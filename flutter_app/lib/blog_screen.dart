import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';

const String pub_query = """
query fetchPubEntries(\$url: String!) {
  pub_entries(url: \$url) {
    success
    errors
    entries {
      title
      text
      pub_name
      pub_url
      url
      author
    }
  }
}

""";

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

const String deleteEntry = """
mutation DeleteBlogEntry(\$url: String!, \$token: String!) {
  deleteBlogEntry(url: \$url, token: \$token) {
    success
    errors
  }
}
""";

const String checkFeed = """
query CheckForFeed(\$url: String!, \$token: String!) {
  checkForFeed(url: \$url, token: \$token) {
    result
    success
    errors
  }
}

""";

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

class PubArticlesWidget extends StatefulWidget {
  final String url;
  final String pub_name;
  const PubArticlesWidget({Key? key, required this.url, required this.pub_name})
      : super(key: key);

  @override
  State<PubArticlesWidget> createState() => _PubArticlesWidgetState();
}

class _PubArticlesWidgetState extends State<PubArticlesWidget> {
  TextEditingController newTaskController = TextEditingController();
  bool isSubscribed = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      token = await getToken();
    } catch (e) {
      print("Error fetching token: $e");
      // Handle error appropriately, like showing an error message
    }
    setState(() {}); // Trigger a rebuild after token is fetched
  }

  @override
  Widget build(BuildContext context) {
    final String url = widget.url;
    print(url);
    return Scaffold(
      body: Query(
          options: QueryOptions(
              document: gql(pub_query),
              pollInterval: const Duration(seconds: 120),
              variables: <String, dynamic>{"url": widget.url}),
          builder: (result, {fetchMore, refetch}) {
            if (result.hasException) {
              print(result.exception.toString());
              return const Center(
                child: Text("Error occurred while fetching data!"),
              );
            }
            if (result.data == null) {
              //print("here's");
              //print(url);
              return Scaffold(
                appBar: AppBar(
                    surfaceTintColor: Colors.transparent,
                    centerTitle: true,
                    automaticallyImplyLeading: true,
                    title:
                        Text(widget.pub_name) // Set your desired app bar title
                    ),
                body: Center(
                  child: Text("Loading...",
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center),
                ),
              );
            }
            final entries = result.data!["pub_entries"]["entries"];
            //final token = await getToken();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  automaticallyImplyLeading: true,
                  title: Text(widget.pub_name),
                ),
                SingleChildScrollView(
                  child: Query(
                      options: QueryOptions(
                          document: gql(checkFeed),
                          variables: <String, dynamic>{
                            "url": widget.url,
                            "token": token
                          }),
                      builder: (result2, {fetchMore, refetch}) {
                        if (result2.data == null) {
                          return Center(
                            child: Text("Loading...",
                                style: TextStyle(fontSize: 25),
                                textAlign: TextAlign.center),
                          );
                        }
                        isSubscribed = result2.data!["checkForFeed"]["result"];
                        return FractionallySizedBox(
                          widthFactor: 0.25,
                          child: Mutation(
                            options: MutationOptions(
                                document: gql(
                                    isSubscribed ? deleteEntry : newerEntry)),
                            builder: (runMutation, result) {
                              return OutlinedButton(
                                  onPressed: () async {
                                    print(token);
                                    print(widget.url);
                                    runMutation(isSubscribed
                                        ? {
                                            'url': widget.url,
                                            'token': token,
                                          }
                                        : {
                                            'url': widget.url,
                                            'token': token,
                                            'category': ""
                                          });

                                    isSubscribed = !isSubscribed;
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text('Subscribed!'),
                                    //     duration:
                                    //         Duration(seconds: 1), // Adjust as needed
                                    //   ),
                                    // );
                                    print(isSubscribed);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                      (states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors.grey.withOpacity(
                                              0.5); // Light color when disabled
                                        }
                                        return isSubscribed
                                            ? Colors.white
                                            : Color(
                                                0xFF511730); // Dark or light color based on subscription
                                      },
                                    ),
                                    foregroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        // Set colors based on subscription state
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          // Button is disabled
                                          return Colors.white; // Light color
                                        }
                                        // Button is enabled
                                        return isSubscribed
                                            ? Colors.black
                                            : Colors
                                                .white; // Dark or light color
                                      },
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)), // Square edges
                                      ),
                                    ),
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal:
                                              12.0), // Customize padding
                                    ),
                                    textStyle: MaterialStateProperty.all(
                                      TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight
                                              .bold), // Change text font size
                                    ),
                                  ),
                                  child: Text(isSubscribed
                                      ? 'Subscribed'
                                      : 'Subscribe'));
                            },
                          ),
                        );
                      }),
                ),
                Expanded(
                  child: Article_List(
                    entries: entries,
                    pub_title: entries[0]['pub_name'],
                    showAppBar: false,
                  ),
                ),
              ],
            );
            // return Article_List(
            //     entries: entries, pub_title: entries[0]['pub_name']);
          }),
    );
  }
}
