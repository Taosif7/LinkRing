import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';
import 'package:link_ring/Screens/HomeScreen/Homepage.dart';
import 'package:link_ring/Screens/SignInScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(BlocProvider(
    create: (BuildContext context) => cubit_app(new state_app(isLoggedIn: FirebaseAuth.instance.currentUser != null)),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.blueGrey.shade50,
          appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              textTheme: TextTheme(headline6: TextStyle(color: Colors.blueGrey, fontSize: 26, fontWeight: FontWeight.bold)))),
      home: context.read<cubit_app>().state.isLoggedIn ? Screen_HomePage() : Screen_SignIn(),
    );
  }
}
