import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/Auth/state_auth.dart';

class cubit_auth extends Cubit<state_auth> {
  cubit_auth(state_auth initialState) : super(initialState);

  Future<bool> signInWithGoogle(BuildContext context, GoogleSignInAuthentication authentication) async {
    AuthCredential credential =
        GoogleAuthProvider.credential(accessToken: authentication.accessToken, idToken: authentication.idToken);

    try {
      await FirebaseAuth.instance.signOut();
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User credentialUser = userCredential.user;

      // If credential is wrong, show some error and return
      if (credentialUser == null) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Some error occurred')));
        return false;
      }

      // Get user model.
      // If it doesn't exist, create new user
      model_user user = await service_users.instance.getUserByEmail(credentialUser.email);
      user ??=
          await service_users.instance.createNewUser(credentialUser.displayName, credentialUser.email, credentialUser.photoURL);

      // Set logged In state
      context.read<cubit_app>().setLoggedInState(credentialUser.email);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-disabled":
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('This account has been disabled.')));
          break;
        case "invalid-credential":
        default:
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Some error occurred')));
      }
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }
}
