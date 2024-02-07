import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'article_screen.dart';
import 'add_feed_screen.dart';

const String query = """
query fetchAllEntries {
  entries {
    success
    errors
    entries {
      title
      text
      pub_name
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
          return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text('Your Inbox'), // Set your desired app bar title
                ),
                body: Container(
                    //height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (ctx, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: InkWell(
                                  child: ListTile(
                                    tileColor: Colors.black12,
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ArticleScreen(
                                                title: entries[i]['title'],
                                                articleText: entries[i]['text'],
                                                pubName: entries[i]['pub_name'],
                                                author: entries[i]['author']))),
                                    subtitle: Text(entries[i]['pub_name']),
                                    title: Text(entries[i]['title']),

                                    // child: Text(entries[i]['title']),
                                    // onTap: () =>
                                    //     launchUrl(Uri.parse(entries[i]['url']))),
                                    trailing: InkWell(
                                      child: IconButton(
                                          icon: Icon(Icons.link,
                                              color: Color.fromARGB(
                                                  255, 111, 55, 2),
                                              size: 30),
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          onPressed: () {
                                            launchUrl(
                                                Uri.parse(entries[i]['url']));
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ))),
              ));
        });
  }
}
