import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'article_list.dart';
import 'token_operations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const String category_query = """
query fetchCategoryEntries(\$category: String!, \$token: String!){
  category_entries(category: \$category, token: \$token) {
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

class CategoryArticlesWidget extends StatefulWidget {
  final String category;
  const CategoryArticlesWidget({Key? key, required this.category})
      : super(key: key);

  @override
  State<CategoryArticlesWidget> createState() => _CategoryArticlesWidgetState();
}

class _CategoryArticlesWidgetState extends State<CategoryArticlesWidget> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
          options: QueryOptions(
              document: gql(category_query),
              pollInterval: const Duration(seconds: 120),
              variables: <String, dynamic>{
                "token": token,
                "category": widget.category
              }),
          builder: (result, {fetchMore, refetch}) {
            if (result.hasException) {
              log(result.exception.toString());
              return const Center(
                child: Text(
                    "There was an issue loading the content... please refresh the page or try again once you have internet connection"),
              );
            }
            if (result.data == null) {
              return Scaffold(
                appBar: AppBar(
                    surfaceTintColor: Colors.transparent,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    title:
                        Text(widget.category) // Set your desired app bar title
                    ),
                body: Center(
                  child: Text("Loading...",
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center),
                ),
              );
            }
            final entries = result.data!["category_entries"]["entries"];
            return Article_List(
                entries: entries,
                pub_title: widget.category,
                showAppBar: true,
                showCategories: false,
                showDescription: false);
          }),
    );
  }
}
