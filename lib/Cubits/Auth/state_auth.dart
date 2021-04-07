import 'package:firebase_auth/firebase_auth.dart';

class state_auth {
  bool isLoggedIn = false;
  User user;

  state_auth({bool loggedIn, User user}) {
    this.isLoggedIn = loggedIn;
    this.user = user;
  }

  state_auth copyWith({bool loggedIn, User user}) {
    return new state_auth(
      loggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
    );
  }
}
