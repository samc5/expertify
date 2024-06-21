import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';
import 'subscribe_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const String savedQuery = """
query fetchSavedEntries (\$token: String!){
  saved_entries(token: \$token) {
    success
    errors
    entries {
      title
      text
      pub_name
      pub_url
      pub_date
      url
      author
    }
  }
}
""";

//final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");
final HttpLink httpLink = HttpLink("https://samcowan.net/graphql");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

class BookmarksWidget extends StatefulWidget {
  const BookmarksWidget({Key? key}) : super(key: key);

  @override
  State<BookmarksWidget> createState() => _BookmarksWidgetState();
}

class _BookmarksWidgetState extends State<BookmarksWidget> {
  TextEditingController newTaskController = TextEditingController();
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    try {
      if (kIsWeb) {
        token = getWebToken();
      } else {
        token = await getToken();
      }
    } catch (e) {
      print("Error fetching token: $e");
      // Handle error appropriately, like showing an error message
    }
    setState(() {}); // Trigger a rebuild after token is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
          options: QueryOptions(
              document: gql(savedQuery),
              pollInterval: const Duration(seconds: 120),
              variables: <String, dynamic>{"token": token}),
          builder: (result, {fetchMore, refetch}) {
            if (result.hasException) {
              print(result.exception.toString());
              return const Center(
                child: Text("Error occurred while fetching data!"),
              );
            }
            if (result.data == null) {
              return Scaffold(
                  appBar: AppBar(
                      surfaceTintColor: Colors.transparent,
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      title: Text("Bookmarks") // Set your desired app bar title
                      ),
                  body: Container());
            }
            final entries = result.data!["saved_entries"]["entries"];
            //final token = await getToken();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text("Bookmarks"),
                ),
                entries != null
                    ? Expanded(
                        child: Article_List(
                            entries: entries.reversed.toList(),
                            pub_title: "Bookmarks",
                            showAppBar: false,
                            showCategories: false,
                            showDescription: false),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                            child: const Text(
                                "You don't have any Bookmarks yet! Swipe left on any article you want to save here and it'll live on this page")))
              ],
            );
            // return Article_List(
            //     entries: entries, pub_title: entries[0]['pub_name']);
          }),
    );
  }
}
