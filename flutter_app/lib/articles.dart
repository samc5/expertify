import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// const String query = """
// query fetchAllEntries {
//   entries {
//     success
//     errors
//     entries {
//       title
//       text
//       pub_name
//       pub_url
//       url
//       author
//     }
//   }
// }
// """;

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
      pub_date
      url
      author
    }
  }
}

""";

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");
final HttpLink androidLink = HttpLink("http://10.0.2.2:5000/graphql");

ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
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
    if (kIsWeb) {
      client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: httpLink,
          cache: GraphQLCache(),
        ),
      );
    } else if (Platform.isAndroid) {
      print("ANDROID");
      client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: androidLink,
          cache: GraphQLCache(),
        ),
      );
    }
    if (token == null) {
      // If token is not fetched yet, you can show a loading indicator or some other widget
      return Center(child: CircularProgressIndicator());
    }
    return Query(
        options: QueryOptions(
            document: gql(personalQuery),
            pollInterval: const Duration(seconds: 40),
            variables: <String, dynamic>{"token": token}),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            print(result.exception.toString());
            final excep = result.exception.toString();
            return Center(
              child: Text(excep),
            );
          }
          if (result.data == null) {
            return const Center(
              child: Text("Loading..."),
            );
          }
          final entries = result.data!["personal_entries"]["entries"];
          //print(entries);
          //print(result.data);
          return Article_List(
            entries: entries,
            pub_title: "Your Inbox",
            showAppBar: true,
          );
        });
  }
}
