import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/GroupPickerScreen.dart';
import 'package:link_ring/Screens/HomeScreen/Homepage.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/LinkMessagesScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/SendLinkScreen.dart';
import 'package:link_ring/Screens/SignInScreen.dart';
import 'package:link_ring/Utils/RegexPatterns.dart';
import 'package:link_ring/Utils/RouteGenerator.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      statusBarIconBrightness: Brightness.dark // dark text for status bar
      ));

  runApp(BlocProvider<cubit_app>(create: (c) => cubit_app(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // Handle intent shared text
    ReceiveSharingIntent.getInitialText().then((url) => HandleSharedText(url));
    ReceiveSharingIntent.getTextStream().listen((url) => HandleSharedText(url));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (routeSettings) => routeGenerator(routeSettings, context),
      theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.blueGrey.shade50,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.transparent, width: 2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey, width: 2)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade800, width: 2)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              filled: true,
              fillColor: Colors.white),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              hoverElevation: 0,
              highlightElevation: 0),
          appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.blueGrey),
              textTheme: TextTheme(headline6: TextStyle(color: Colors.blueGrey, fontSize: 26, fontWeight: FontWeight.bold)))),
      home: context.read<cubit_app>().auth.state.isLoggedIn ? Screen_HomePage() : Screen_SignIn(),
    );
  }

  void HandleSharedText(String url) {
    if (RegexPatterns.links.hasMatch(url) && !url.toLowerCase().startsWith("http://linkring.taosif7.com/joingroup")) {
      navigatorKey.currentState.push(GroupPickerScreen.getRoute(context, showOnlyOwnedGroups: true)).then((group) {
        if (group != null) {
          navigatorKey.currentState.push(SendLinkScreen.getRoute(context, group, url)).then((value) {
            navigatorKey.currentState.push(LinkMessagesScreen.getRoute(context, group));
          });
        }
      });
    }
  }
}
