import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'article_screen.dart';
import 'blog_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'token_operations.dart';
import 'category_screen.dart';
import 'navigation_bar_controller.dart';
import 'token_operations.dart';
import 'login_screen.dart';

String categoryQuery = """
query fetch_categories(\$token: String!) {
  fetch_categories(token: \$token) {
    success
    errors
    categories
  }
}
""";

class Article_List extends StatefulWidget {
  const Article_List(
      {super.key,
      required this.entries,
      required this.pub_title,
      required this.showAppBar});

  final entries;
  final String pub_title;
  final bool showAppBar;

  // String? token;
  @override
  _ArticleListState createState() => _ArticleListState();

//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();
//   }

// Future<void> _fetchToken() async {
//     try {
//       token = await getToken();
//     } catch (e) {
//       print("Error fetching token: $e");
//       // Handle error appropriately, like showing an error message
//     }
//     setState(() {}); // Trigger a rebuild after token is fetched
//   }
}

class _ArticleListState extends State<Article_List> {
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
    if (token == null) {
      // If token is not fetched yet, you can show a loading indicator or some other widget
      return Center(child: CircularProgressIndicator());
    }

    if (widget.entries == null) {
      return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  automaticallyImplyLeading:
                      widget.pub_title == 'Your Inbox' ? false : true,
                  leading: widget.pub_title == 'Your Inbox'
                      ? BackButton(color: Colors.black)
                      : null,
                  title: Text(widget.pub_title),
                )
              : null,
          body: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Center(
                  child: Text(
                      "You don't have any feeds yet! Add an RSS feed and it'll show up here."))));
    }
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: widget.pub_title == 'Your Inbox'
                  ? null
                  : BackButton(color: Colors.black),
              actions: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                )
              ],
              title: Text(widget.pub_title),
            )
          : null,
      drawer: Query(
          options: QueryOptions(
              document: gql(categoryQuery),
              variables: <String, dynamic>{"token": token}),
          builder: (result, {fetchMore, refetch}) {
            if (result.data == null) {
              return Drawer(
                  // Drawer content goes here
                  child: Center(
                child: Text("Loading..."),
              ));
            }
            final categories = result.data!["fetch_categories"]["categories"];
            print(categories);
            return Drawer(
              backgroundColor: Colors.white,
              // Drawer content goes here
              child: ListView.builder(
                itemCount: categories.length + 2,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return ListTile(
                        title: Text('All Feeds'),
                        onTap: () {
                          Scaffold.of(context).closeDrawer();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavigationBarController()));
                        });
                  } else if (index > categories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 80.0, right: 80.0),
                      child: ElevatedButton(
                          child: Text('Log Out'),
                          //tileColor: const Color.fromARGB(255, 184, 205, 215),
                          onPressed: () {
                            deleteToken();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          }),
                    );
                  } else {
                    final categoryIndex = index - 1;
                    return ListTile(
                        title: Text(categories[categoryIndex]),
                        onTap: () {
                          Scaffold.of(context).closeDrawer();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryArticlesWidget(
                                      category: categories[categoryIndex])));
                        });
                  }
                },
              ),
            );
          }),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Container(
            //height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
                itemCount: widget.entries.length,
                itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromARGB(
                                            157, 150, 150, 150)))),
                            child: ListTile(
                              tileColor: Color.fromARGB(255, 255, 255, 255),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ArticleScreen(
                                          pub_url: widget.entries[i]['pub_url'],
                                          title: widget.entries[i]['title'],
                                          articleText: widget.entries[i]
                                              ['text'],
                                          pubName: widget.entries[i]
                                              ['pub_name'],
                                          author: widget.entries[i]
                                              ['author']))),
                              subtitle: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PubArticlesWidget(
                                                  pub_name: widget.entries[i]
                                                      ['pub_name'],
                                                  url: widget.entries[i]
                                                      ['pub_url']))),
                                  child: Text(widget.entries[i]['pub_name'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2)),

                              title: Text(widget.entries[i]['title'],
                                  overflow: TextOverflow.ellipsis, maxLines: 2),

                              // child: Text(entries[i]['title']),
                              // onTap: () =>
                              //     launchUrl(Uri.parse(entries[i]['url']))),
                              trailing: InkWell(
                                child: IconButton(
                                    icon: Icon(Icons.link,
                                        color: Color.fromARGB(255, 111, 55, 2),
                                        size: 30),
                                    //padding: const EdgeInsets.only(right: 15),
                                    onPressed: () {
                                      launchUrl(
                                          Uri.parse(widget.entries[i]['url']));
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))),
      ),
    );
  }
}
