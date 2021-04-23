import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/API/Services/service_messaging.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/Auth/state_auth.dart';

class cubit_auth extends Cubit<state_auth> {
  factory cubit_auth() {
    if (FirebaseAuth.instance.currentUser != null)
      return cubit_auth.init(state_auth(loggedIn: true, user: FirebaseAuth.instance.currentUser));
    else
      return cubit_auth.init(state_auth(loggedIn: false));
  }

  cubit_auth.init(state_auth initialState) : super(initialState);

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

      // Get push token
      String messagingToken = await service_messaging.instance.getPushToken();

      // find user that holds this push token already,
      // then unset this token to it, and to groups
      model_user holder_user = await service_users.instance.getUserByPushToken(messagingToken);
      if (holder_user != null) {
        service_users.instance.updateUserToken(holder_user.id, null);
        service_members.instance.updateMemberTokens(holder_user.joinedGroupsIds, holder_user.id, null);
        service_members.instance.updateMemberTokens(holder_user.waitingGroupsIds, holder_user.id, null);
      }

      // set push token update on server and in groups
      service_users.instance.updateUserToken(user.id, messagingToken);
      service_members.instance.updateMemberTokens(user.joinedGroupsIds, user.id, messagingToken);
      service_members.instance.updateMemberTokens(user.waitingGroupsIds, user.id, messagingToken);

      // Set logged In state
      context.read<cubit_app>().setLoggedInState(credentialUser.email);
      emit(state.copyWith(loggedIn: true, user: credentialUser));
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

  Future<void> signOut(BuildContext context) async {
    // Update signOut
    model_user user = context.read<cubit_app>().state.currentUser;
    await service_users.instance.updateUserToken(user.id, null);
    service_members.instance.updateMemberTokens(user.joinedGroupsIds, user.id, null);
    service_members.instance.updateMemberTokens(user.waitingGroupsIds, user.id, null);

    // Set app signOut state
    await FirebaseAuth.instance.signOut();
    emit(new state_auth(loggedIn: false));
    context.read<cubit_app>().signOut();
  }
}
