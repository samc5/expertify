import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';
import 'subscribe_button.dart';

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
      pub_date
      url
      author
    }
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
                  child: SubscribeButton(widget: widget, token: token),
                ),
                Expanded(
                  child: Article_List(
                    entries: entries,
                    pub_title: entries[0]['pub_name'],
                    showAppBar: false,
                    showCategories: false,
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
