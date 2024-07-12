import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");
//final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");
final HttpLink httpLink = HttpLink("https://samcowan.net/graphql");
final HttpLink androidLink = HttpLink("http://10.0.2.2:5000/graphql");
// bool _certificateCheck(X509Certificate cert, String host, int port) =>
//     host == 'local.domain.ext'; // <- change

//   SecurityContext securityContext = SecurityContext.defaultContext;
//   securityContext.setTrustedCertificates('path_to_certificate.crt');

// Create a HttpClient with the trusted certificate
// HttpClient client = HttpClient(context: securityContext);

ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

Future<void> main() async {
  await dotenv.load(fileName: "./.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: httpLink,
          cache: GraphQLCache(),
        ),
      );
    } else if (Platform.isAndroid) {
      print("ANDROID");
      client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: androidLink,
          cache: GraphQLCache(),
        ),
      );
    }
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expertify',
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              bodySmall: GoogleFonts.sourceSerif4(fontSize: 12),
              bodyMedium: GoogleFonts.sourceSerif4(fontSize: 14),
              bodyLarge: GoogleFonts.sourceSerif4(fontSize: 16),
              displayLarge: GoogleFonts.sourceSerif4(fontSize: 16),
              displayMedium: GoogleFonts.sourceSerif4(fontSize: 11),
              displaySmall: GoogleFonts.sourceSerif4(fontSize: 11),
              titleLarge: GoogleFonts.sourceSerif4(fontSize: 24),
              titleMedium: GoogleFonts.sourceSerif4(fontSize: 16),
              titleSmall: GoogleFonts.sourceSerif4(fontSize: 16),
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
