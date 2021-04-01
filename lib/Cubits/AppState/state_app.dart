import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';

class state_app {
  bool isLoggedIn = false;
  model_user currentUser;
  List<model_group> groups = [];

  state_app({this.isLoggedIn, this.groups = const [], this.currentUser});

  state_app copyWith({bool isLoggedIn, List<model_group> joinedGroups, model_user user}) {
    state_app newState = new state_app(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      groups: joinedGroups ?? this.groups,
      currentUser: user ?? this.currentUser,
    );
    return newState;
  }
}
