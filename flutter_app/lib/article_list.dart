import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'article_screen.dart';
import 'blog_screen.dart';

class Article_List extends StatelessWidget {
  const Article_List(
      {super.key, required this.entries, required this.pub_title});

  final entries;
  final String pub_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(pub_title), // Set your desired app bar title
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Container(
            //height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: InkWell(
                          child: ListTile(
                            tileColor: Colors.black12,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArticleScreen(
                                        pub_url: entries[i]['pub_url'],
                                        title: entries[i]['title'],
                                        articleText: entries[i]['text'],
                                        pubName: entries[i]['pub_name'],
                                        author: entries[i]['author']))),
                            subtitle: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PubArticlesWidget(
                                            url: entries[i]['pub_url']))),
                                child: Text(
                                  entries[i]['pub_name'],
                                )),

                            title: Text(entries[i]['title']),

                            // child: Text(entries[i]['title']),
                            // onTap: () =>
                            //     launchUrl(Uri.parse(entries[i]['url']))),
                            trailing: InkWell(
                              child: IconButton(
                                  icon: Icon(Icons.link,
                                      color: Color.fromARGB(255, 111, 55, 2),
                                      size: 30),
                                  padding: const EdgeInsets.only(right: 15),
                                  onPressed: () {
                                    launchUrl(Uri.parse(entries[i]['url']));
                                  }),
                            ),
                          ),
                        ),
                      ),
                    ))),
      ),
    );
  }
}
