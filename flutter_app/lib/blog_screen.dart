import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';

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

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

class PubArticlesWidget extends StatefulWidget {
  final String url;
  const PubArticlesWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<PubArticlesWidget> createState() => _PubArticlesWidgetState();
}

class _PubArticlesWidgetState extends State<PubArticlesWidget> {
  TextEditingController newTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String url = widget.url;
    print(url);
    return Query(
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
            return Text("loaaaading...");
          }
          //   return const Center(
          //     child: Text("NO data received",
          //         style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
          //   );
          // }
          final entries = result.data!["pub_entries"]["entries"];
          return Article_List(
              entries: entries, pub_title: entries[0]['pub_name']);
        });
  }
}
