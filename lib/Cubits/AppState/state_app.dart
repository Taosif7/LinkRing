import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';

class state_app {
  bool isLoggedIn = false;
  bool isLoading = false;
  model_user currentUser;
  List<model_group> groups = [];

  state_app({this.isLoggedIn, this.groups = const [], this.currentUser, this.isLoading});

  state_app copyWith({bool isLoggedIn, List<model_group> joinedGroups, model_user user, bool isLoading}) {
    state_app newState = new state_app(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      groups: joinedGroups ?? this.groups,
      currentUser: user ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
    );
    return newState;
  }
}
