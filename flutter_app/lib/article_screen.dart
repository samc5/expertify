import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'blog_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleScreen extends StatelessWidget {
  final String title;
  final String articleText;
  final String pubName;
  final String author;
  final String pub_url;

  const ArticleScreen(
      {Key? key,
      required this.title,
      required this.articleText,
      required this.pubName,
      required this.author,
      required this.pub_url})
      : super(key: key);

  static const routeName = '/article';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: InkWell(
            child: Text(pubName),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PubArticlesWidget(
                        pub_name: pubName,
                        url: pub_url)))), // Set your desired app bar title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(title,
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 5),
              Center(
                child: author == "0"
                    ? SizedBox(height: 5)
                    : Text(author,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(
                  height: 10), // Add some spacing between title and content
              LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  double thresholdWidth = 600.0;

                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Center(
                      child: Container(
                        width:
                            maxWidth < thresholdWidth ? null : thresholdWidth,
                        child: HtmlWidget(articleText,
                            textStyle: GoogleFonts.sourceSerif4(fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
