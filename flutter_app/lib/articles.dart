import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';

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

const String personalQuery = """
query fetchPersonalEntries(\$token: String!) {
  personal_entries(token: \$token) {
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
  String? token;
  TextEditingController newTaskController = TextEditingController();

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
    if (token == null) {
      // If token is not fetched yet, you can show a loading indicator or some other widget
      return CircularProgressIndicator();
    }
    return Query(
        options: QueryOptions(
            document: gql(personalQuery),
            pollInterval: const Duration(seconds: 40),
            variables: <String, dynamic>{"token": token}),
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
          final entries = result.data!["personal_entries"]["entries"];
          //print(entries);
          //print(result.data);
          return Article_List(entries: entries, pub_title: "Your Inbox");
        });
  }
}
