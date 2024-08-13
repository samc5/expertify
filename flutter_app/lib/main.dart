import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");
//final HttpLink httpLink = HttpLink("https://samcowan.net/graphql");
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
              scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
              textTheme: TextTheme(
                bodySmall: GoogleFonts.firaSans(fontSize: 12),
                bodyMedium: GoogleFonts.firaSans(fontSize: 14),
                bodyLarge: GoogleFonts.firaSans(fontSize: 16),
                displayLarge: GoogleFonts.firaSans(fontSize: 16),
                displayMedium: GoogleFonts.firaSans(fontSize: 11),
                displaySmall: GoogleFonts.firaSans(fontSize: 11),
                titleLarge: GoogleFonts.firaSans(fontSize: 24),
                titleMedium: GoogleFonts.firaSans(fontSize: 16),
                titleSmall: GoogleFonts.firaSans(fontSize: 16),
              ),
              appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xFF511730).withOpacity(0.1)),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  selectedItemColor: Color(0xFF511730))),
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
