import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/IndefiniteProgressScreen.dart';

class Screen_SignIn extends StatelessWidget {
  GoogleSignIn _googleSignIn;

  Screen_SignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/plus.me',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SignInButton(
              Buttons.Google,
              onPressed: () => _handleSignIn(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      // Sign in with google
      await _googleSignIn.signOut();
      GoogleSignInAccount account = await _googleSignIn.signIn();

      // Try signing into the system
      showIndefiniteProgressScreen(context);
      bool signIn = await context.read<cubit_app>().auth.signInWithGoogle(context, await account.authentication);
      hideIndefiniteProgressScreen(context);

      // Move to homescreen on successful Sign-In
      if (signIn) Navigator.of(context).pushReplacementNamed('home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Some error occurred")));
      print(error);
    }
  }
}
