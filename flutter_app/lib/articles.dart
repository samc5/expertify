import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';

const String query = """
query fetchAllEntries {
  entries {
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

class ArticlesWidget extends StatefulWidget {
  const ArticlesWidget({Key? key}) : super(key: key);

  @override
  State<ArticlesWidget> createState() => _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<ArticlesWidget> {
  TextEditingController newTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(query),
            pollInterval: const Duration(seconds: 40),
            variables: const <String, dynamic>{"variableName": "value"}),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            print(result.exception.toString());
            return const Center(
              child: Text("Error occurred while fetching data!"),
            );
          }
          if (result.data == null) {
            return const Center(
              child: Text("No data received!"),
            );
          }
          final entries = result.data!["entries"]["entries"];
          return Article_List(entries: entries, pub_title: "Your Inbox");
        });
  }
}
