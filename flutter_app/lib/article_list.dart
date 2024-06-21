import 'package:flutter/material.dart';
import 'package:flutter_app/add_feed_screen.dart';
import 'article_screen.dart';
import 'blog_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'token_operations.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'settings.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'subscribe_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

String categoryQuery = """
query fetch_categories(\$token: String!) {
  fetch_categories(token: \$token) {
    success
    errors
    categories
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

String saveArticle = """
mutation saveArticle(\$article: BlogEntryInput!, \$token: String!) {
  saveArticle(article: \$article, token: \$token) {
    success
    errors
    url
  }
}
""";

const String categoryEntries = """
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

class Article_List extends StatefulWidget {
  const Article_List(
      {super.key,
      required this.entries,
      required this.pub_title,
      required this.showAppBar,
      required this.showCategories,
      required this.showDescription});

  final entries;
  final String pub_title;
  final bool showAppBar;
  final bool showCategories;
  final bool showDescription;
  // String? token;
  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<Article_List> {
  String? token;
  int? _value;
  String? selectedCategory;
  List<dynamic>? catResults;
  List<dynamic>? categoriesList;
  bool? nullColor;

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

  Future<void> _fetchCategoryEntries() async {
    final client = GraphQLProvider.of(context).value;
    final QueryOptions options = QueryOptions(
      document: gql(categoryEntries),
      variables: {
        'token': token,
        'category': selectedCategory,
      },
    );
    final QueryResult result = await client.query(options);
    if (!result.hasException) {
      setState(() {
        catResults = result.data!['category_entries']['entries'];
      });
    } else {
      print("Error fetching category entries: ${result.exception.toString()}");
    }
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
                      "You don't have any feeds yet! Head to the Discover page to subscribe to one and it'll show up here."))));
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
                    return Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingsScreen()));
                            }),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddFeedScreen()));
                          },
                        ),
                      ],
                    );
                  },
                )
              ],
              title: Text(widget.pub_title),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                      itemCount: widget.showCategories
                          ? widget.entries.length + 1
                          : widget.entries.length,
                      itemBuilder: (ctx, i) {
                        int updatedIndex =
                            (widget.showCategories || widget.showDescription)
                                ? (i - 1)
                                : i;
                        if (i == 0 && widget.showCategories) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: categoriesList == null
                                    ? Query(
                                        options: QueryOptions(
                                            document: gql(categoryQuery),
                                            variables: <String, dynamic>{
                                              "token": token
                                            }),
                                        builder: (result2,
                                            {fetchMore, refetch}) {
                                          if (result2.data == null) {
                                            return Center(
                                              child: Text(""),
                                            );
                                          }
                                          final categories =
                                              result2.data!["fetch_categories"]
                                                  ["categories"];
                                          categoriesList = categories;
                                          return Wrap(
                                            spacing: 10.0,
                                            children: List<Widget>.generate(
                                              categories.length,
                                              (int index) {
                                                return ChoiceChip(
                                                  label: Text(
                                                    categories[index],
                                                    style: (_value == index)
                                                        ? TextStyle(
                                                            color: Colors.black)
                                                        : TextStyle(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  selected: _value == index,
                                                  backgroundColor:
                                                      Color(0xFF507255),
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      catResults = null;
                                                      _value = selected
                                                          ? index
                                                          : null;
                                                      selectedCategory = (_value !=
                                                              null)
                                                          ? categories[_value]
                                                          : null; // may or may not work
                                                      _fetchCategoryEntries();
                                                    });
                                                  },
                                                );
                                              },
                                            ).toList(),
                                          );
                                        })
                                    : Wrap(
                                        spacing: 10.0,
                                        children: List<Widget>.generate(
                                          categoriesList!.length,
                                          (int index) {
                                            return ChoiceChip(
                                              label: Text(
                                                categoriesList![index],
                                                style: (_value == index)
                                                    ? TextStyle(
                                                        color: Colors.black)
                                                    : TextStyle(
                                                        color: Colors.white),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              selected: _value == index,
                                              backgroundColor:
                                                  Color(0xFF507255),
                                              onSelected: (bool selected) {
                                                setState(() {
                                                  catResults = null;
                                                  _value =
                                                      selected ? index : null;
                                                  selectedCategory = (_value !=
                                                          null)
                                                      ? categoriesList![_value!]
                                                      : null; // may or may not work
                                                  _fetchCategoryEntries();
                                                });
                                              },
                                            );
                                          },
                                        ).toList(),
                                      ),
                              ),
                            ),
                          );
                        } else if (widget.showDescription && i == 0) {
                          return Column(
                            children: [
                              // Query(
                              //     options: QueryOptions(
                              //         document: gql(checkFeed),
                              //         variables: <String, dynamic>{
                              //           "url": widget.entries[0]['pub_url'],
                              //           "token": token
                              //         }),
                              //     builder: (checkResult, {fetchMore, refetch}) {
                              //       if (checkResult.data == null) {
                              //         return Container();
                              //       }
                              //       return
                              SubscribeButton(
                                url: widget.entries[0]['pub_url'],
                                token: token,
                              ),

                              Padding(padding: EdgeInsets.all(8.0)),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: Center(
                                    child: Text(
                                        widget.entries[0]['description'],
                                        textAlign: TextAlign.center)),
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Divider(),
                              )
                            ],
                          );
                        }
                        final isLoading =
                            selectedCategory != null && catResults == null;
                        final isInCatResultsRange = selectedCategory != null &&
                            catResults != null &&
                            i < catResults!.length;
                        final shouldRenderTile = !isLoading &&
                            (selectedCategory == null || isInCatResultsRange);

                        if (isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: SpinKitPulsingGrid(
                                itemBuilder: (BuildContext context, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                              );
                            })),
                          );
                        }
                        // catResults != null ? print("yes cat") : print("no cat");
                        if (shouldRenderTile) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 12.0),
                              child: InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: _getBorderColor(i)))),
                                  child: selectedCategory != null &&
                                          catResults == null
                                      ? Container()
                                      : selectedCategory != null
                                          ? i < catResults!.length
                                              ? ArticleTile(
                                                  entries: catResults,
                                                  index: updatedIndex,
                                                  onDismissed: (direction) {
                                                    if (direction ==
                                                        DismissDirection
                                                            .startToEnd) {
                                                      // Perform your action here (e.g., save as bookmark)
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              "Article saved as bookmark"),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  token: token)
                                              : Container()
                                          : ArticleTile(
                                              entries: widget.entries,
                                              index: updatedIndex,
                                              onDismissed: (direction) {
                                                if (direction ==
                                                    DismissDirection
                                                        .startToEnd) {
                                                  // Perform your action here (e.g., save as bookmark)
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Article saved as bookmark"),
                                                    ),
                                                  );
                                                }
                                              },
                                              token: token),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
                )),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor(i) {
    if (selectedCategory != null && catResults == null) {
      return Color.fromARGB(157, 150, 150, 150); // Grey color
    } else if (selectedCategory != null && i >= catResults!.length) {
      return Colors.white; // White color when index is out of bounds
    } else {
      return Color.fromARGB(157, 150, 150, 150); // Default grey color
    }
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(
      {super.key,
      required this.onDismissed,
      //required this.widget,
      required this.entries,
      required this.index,
      required this.token});
  final List<dynamic>? entries;
  final int index;
  final DismissDirectionCallback onDismissed;
  final String? token;

  @override
  TileState createState() => TileState();
}

class TileState extends State<ArticleTile> {
  SwipeActionController? controller;

  /// 在initState
  @override
  void initState() {
    super.initState();
    controller = SwipeActionController();
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
        options: MutationOptions(document: gql(saveArticle)),
        builder: (runMutation, result, {fetchMore, refetch}) {
          return SwipeActionCell(
            key: Key(widget.index.toString()),
            controller: controller,
            trailingActions: <SwipeAction>[
              SwipeAction(
                  performsFirstActionWithFullSwipe: true,
                  title: "SAVE",
                  onTap: (CompletionHandler handler) async {
                    /// await handler(true) : will delete this row
                    /// And after delete animation,setState will called to
                    /// sync your data source with your UI

                    await handler(false);
                    setState(() {
                      widget.entries![widget.index].remove('__typename');
                      runMutation({
                        "article": widget.entries![widget.index],
                        "token": widget.token
                      });
                    });
                  },
                  color: Color(0xFF511730)),
            ],
            child: ListTile(
              tileColor: Color.fromARGB(255, 255, 255, 255),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ArticleScreen(
                          pub_url: widget.entries![widget.index]['pub_url'],
                          title: widget.entries![widget.index]['title'],
                          articleText: widget.entries![widget.index]['text'],
                          pubName: widget.entries![widget.index]['pub_name'],
                          author: widget.entries![widget.index]['author'],
                          url: widget.entries![widget.index]['url']))),
              subtitle: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PubArticlesWidget(
                              pub_name: widget.entries![widget.index]
                                  ['pub_name'],
                              url: widget.entries![widget.index]['pub_url']))),
                  child: Text(widget.entries![widget.index]['pub_name'],
                      overflow: TextOverflow.ellipsis, maxLines: 2)),
              title: Text(widget.entries![widget.index]['title'],
                  overflow: TextOverflow.ellipsis, maxLines: 2),
              trailing: Text(widget.entries![widget.index]['pub_date']),
            ),
          );
        });
  }
}
