import 'package:flutter/material.dart';
import 'articles.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'navigation_bar_controller.dart';
import 'login_screen.dart';
import 'dart:io';

const String query = """
query fetchAllTodos {
  todos {
    success
    errors
    todos {
      name
      is_executed
      id
    }
  }
}
""";

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");

// bool _certificateCheck(X509Certificate cert, String host, int port) =>
//     host == 'local.domain.ext'; // <- change

//   SecurityContext securityContext = SecurityContext.defaultContext;
//   securityContext.setTrustedCertificates('path_to_certificate.crt');

// Create a HttpClient with the trusted certificate
// HttpClient client = HttpClient(context: securityContext);

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            textTheme: TextTheme(
              bodySmall: TextStyle(fontSize: 11, fontFamily: "Arial"),
            ),
          ),
          initialRoute: '/',
          // home: const MyHomePage(title: 'Reader app'),
          home: LoginScreen(),
          // home: BottomNavigationBarController(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      // body: ArticlesWidget(),
      body: LoginScreen(),
    );
  }
}
