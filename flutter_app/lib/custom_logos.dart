import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GithubLink extends StatelessWidget {
  const GithubLink({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Image.asset('assets/github.png', width: 20, height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
              child: Text("View Source Code",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                launchUrl(Uri.parse("https://github.com/samc5/expertify"));
              }),
        ),
      ],
    );
  }
}
