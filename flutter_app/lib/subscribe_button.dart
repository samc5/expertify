import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String newerEntry = """
mutation newEntry(\$url: String!, \$token: String!, \$categories: [String]!){
  createCategoriesEntry(url: \$url, token: \$token, categories: \$categories) {
    success
    errors
    entries {
        url
        title
    }
  }
}
""";

const String deleteEntry = """
mutation DeleteBlogEntry(\$url: String!, \$token: String!) {
  deleteBlogEntry(url: \$url, token: \$token) {
    success
    errors
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

String categoryQuery = """
query fetch_categories(\$token: String!) {
  fetch_categories(token: \$token) {
    success
    errors
    categories
  }
}
""";

class MultiSelect extends StatefulWidget {
  final List<String> categories;
  final String url;
  final String? token;
  const MultiSelect(
      {Key? key,
      required this.categories,
      required this.url,
      required this.token})
      : super(key: key);
  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedCategories = [];
  final TextEditingController categoryValue = TextEditingController();

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCategories.add(itemValue);
      } else {
        _selectedCategories.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context, {'action': 'cancel'});
  }

// this function is called when the Submit button is tapped
  List<String> _submit() {
    Navigator.pop(
        context, {'action': 'submit', 'categories': _selectedCategories});
    if (categoryValue.text.isNotEmpty &&
        !widget.categories.contains(categoryValue.text)) {
      setState(() {
        _selectedCategories.add(categoryValue.text);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscribed!'),
        duration: Duration(seconds: 1), // Adjust as needed
      ),
    );
    return _selectedCategories;
  }

  void _addCategory() {
    final String newCategory = categoryValue.text;
    if (newCategory.isNotEmpty && !widget.categories.contains(newCategory)) {
      setState(() {
        widget.categories.add(newCategory);
        categoryValue.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
          'Select which categories you want to include this feed under'),
      content: SingleChildScrollView(
          child: ListBody(children: [
        ...widget.categories.map((item) {
          return CheckboxListTile(
            value: _selectedCategories.contains(item),
            title: Text(item),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
          );
        }).toList(),
        ListTile(
          title: TextField(
            controller: categoryValue,
            decoration: InputDecoration(
              labelText: 'Add Category',
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ),
      ])),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        Mutation(
            options: MutationOptions(document: gql(newerEntry)),
            builder: (runMutation, result, {fetchMore, refetch}) {
              return ElevatedButton(
                onPressed: () {
                  runMutation({
                    'url': widget.url,
                    'token': widget.token,
                    'categories': _submit()
                  });
                },
                child: const Text('Submit'),
              );
            }),
      ],
    );
  }
}

class SubscribeButton extends StatefulWidget {
  const SubscribeButton({super.key, required this.url, required this.token});

  final String url;
  final String? token;
  //final bool isSubscribed;

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  bool isSubscribed2 = false;
  bool isLoading = true;
  bool? changed;
  bool? old;
  String buttonText = "Subscribe";
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> _checkFeed() async {
    final client = GraphQLProvider.of(context).value;
    final QueryOptions options = QueryOptions(
      document: gql(checkFeed),
      variables: {
        'token': widget.token,
        'url': widget.url,
      },
    );
    setState(() {
      //isLoading = false;
    });

    final QueryResult result = await client.query(options);
    setState(() {
      //isLoading = true;
      if (result.data != null && !result.hasException) {
        isSubscribed2 = result.data!['checkForFeed']['result'];
        //buttonText = isSubscribed2 ? "Subscribed" : "Subscribe";
      }
    });
  }

  Future<void> _loadSubscriptionState() async {
    final storedSubscribed = await _secureStorage.read(key: widget.url);

    if (storedSubscribed == null) {
      await _checkFeed();
    } else {
      // Info found in secure storage, use it
      setState(() {
        isSubscribed2 = storedSubscribed == 'true';
        // buttonText = isSubscribed2 ? "Subscribed" : "Subscribe";
      });
    }
    isLoading = false;
  }

  Future<void> _saveSubscriptionState(bool subscribed) async {
    await _secureStorage.write(key: widget.url, value: subscribed.toString());
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _loadSubscriptionState();
  }

  @override
  Widget build(BuildContext context) {
    // _checkFeed();
    if (isLoading) {
      return CircularProgressIndicator();
    }
    //return
    // Query(
    //     options: QueryOptions(
    //         document: gql(checkFeed),
    //         variables: <String, dynamic>{
    //           "url": widget.url,
    //           "token": widget.token
    //         }),
    //     builder: (result2, {fetchMore, refetch}) {
    //       // print("building with" + isSubscribed2.toString());
    //       if (result2.data == null) {
    //         return Center(
    //           child: Text("",
    //               style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
    //         );
    //       }
    //       isSubscribed2 = result2.data!["checkForFeed"]["result"];
    return FractionallySizedBox(
      widthFactor: 0.23,
      child: Mutation(
        options: MutationOptions(document: gql(deleteEntry)),
        builder: (runMutation, result, {fetchMore, refetch}) {
          return Query(
              options: QueryOptions(
                  document: gql(categoryQuery),
                  variables: <String, dynamic>{"token": widget.token}),
              builder: (categoriesResult, {fetchMore, refetch}) {
                if (categoriesResult.data == null) {
                  return Center(
                    child: Text("",
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center),
                  );
                }
                List<dynamic> categories =
                    categoriesResult.data?['fetch_categories']['categories'] ??
                        [];
                List<String> categoryList =
                    categories.whereType<String>().toList();
                //if (isSubscribed2) {}
                return OutlinedButton(
                    onPressed: () async {
                      // isSubscribed2 = !isSubscribed2;
                      if (!isSubscribed2) {
                        var result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiSelect(
                                  categories: categoryList,
                                  url: widget.url,
                                  token: widget.token);
                            });
                        print(result);
                        if (result != null && result['action'] == 'submit') {
                          //    isLoading = true;
                          setState(() {
                            isSubscribed2 = true;
                            // buttonText = "Subscribed";
                          });
                          _saveSubscriptionState(true);
                          //        isLoading = false;
                        } else {
                          // isSubscribed2 = false;
                          // buttonText = "Subscribe";
                        }
                      } else {
                        runMutation({
                          'url': widget.url,
                          'token': widget.token,
                        });
                        setState(() {
                          isSubscribed2 = false;
                          //buttonText = "unsubscribed";
                        });
                        _saveSubscriptionState(false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unsubscribed!'),
                            duration: Duration(seconds: 1), // Adjust as needed
                          ),
                        );
                      }
                      // old = isSubscribed2;
                      // _checkFeed();
                      print("new issubscribed2: " + isSubscribed2.toString());
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey
                                .withOpacity(0.5); // Light color when disabled
                          }
                          return isSubscribed2
                              ? Colors.white
                              : Color(
                                  0xFF511730); // Dark or light color based on subscription
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          // Set colors based on subscription state
                          if (states.contains(MaterialState.disabled)) {
                            // Button is disabled
                            return Colors.white; // Light color
                          }
                          // Button is enabled
                          return isSubscribed2
                              ? Colors.black
                              : Colors.white; // Dark or light color
                        },
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(4)), // Square edges
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 10.0), // Customize padding
                      ),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                            fontSize: 12.0,
                            fontWeight:
                                FontWeight.bold), // Change text font size
                      ),
                    ),
                    child: Text(isSubscribed2 ? "Subscribed" : "Subscribe"));
              });
        },
      ),
    );
    //    });
  }
}
