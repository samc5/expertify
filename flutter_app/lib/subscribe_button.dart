import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_screen.dart';

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
  final bool isSubscribed;
  final String url;
  final String? token;
  const MultiSelect(
      {Key? key,
      required this.categories,
      required this.isSubscribed,
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
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  List<String> _submit() {
    Navigator.pop(context, _selectedCategories);
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
      title: const Text('Select Topics'),
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
  const SubscribeButton({
    super.key,
    required this.widget,
    required this.token,
  });

  final PubArticlesWidget widget;
  final String? token;
  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  bool isSubscribed = false;
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(checkFeed),
            variables: <String, dynamic>{
              "url": widget.widget.url,
              "token": widget.token
            }),
        builder: (result2, {fetchMore, refetch}) {
          bool isSubscribed;
          if (result2.data == null) {
            return Center(
              child: Text("",
                  style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
            );
          }
          isSubscribed = result2.data!["checkForFeed"]["result"];
          return FractionallySizedBox(
            widthFactor: 0.25,
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
                      List<dynamic> categories = categoriesResult
                              .data?['fetch_categories']['categories'] ??
                          [];
                      List<String> categoryList =
                          categories.whereType<String>().toList();
                      return OutlinedButton(
                          onPressed: () async {
                            isSubscribed = !isSubscribed;
                            // print("post-state");
                            // print(isSubscribed);
                            if (isSubscribed) {
                              List<String>? results = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MultiSelect(
                                        categories: categoryList,
                                        isSubscribed: isSubscribed,
                                        url: widget.widget.url,
                                        token: widget.token);
                                  });
                            } else {
                              runMutation({
                                'url': widget.widget.url,
                                'token': widget.token,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unsubscribed!'),
                                  duration:
                                      Duration(seconds: 1), // Adjust as needed
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey.withOpacity(
                                      0.5); // Light color when disabled
                                }
                                return isSubscribed
                                    ? Colors.white
                                    : Color(
                                        0xFF511730); // Dark or light color based on subscription
                              },
                            ),
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                // Set colors based on subscription state
                                if (states.contains(MaterialState.disabled)) {
                                  // Button is disabled
                                  return Colors.white; // Light color
                                }
                                // Button is enabled
                                return isSubscribed
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
                                  horizontal: 12.0), // Customize padding
                            ),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                  fontSize: 14.0,
                                  fontWeight:
                                      FontWeight.bold), // Change text font size
                            ),
                          ),
                          child:
                              Text(isSubscribed ? 'Subscribed' : 'Subscribe'));
                    });
              },
            ),
          );
        });
  }
}
