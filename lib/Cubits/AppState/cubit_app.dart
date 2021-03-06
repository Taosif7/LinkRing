import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';
import 'package:link_ring/Cubits/Auth/cubit_auth.dart';

class cubit_app extends Cubit<state_app> {
  // Sub Cubits
  cubit_auth auth;

  cubit_app() : super(state_app(isLoading: true)) {
    // Create sub cubits
    auth = new cubit_auth();

    // If its logged in, set app state to be logged in
    if (auth.state.isLoggedIn) setLoggedInState(auth.state.user.email);
  }

  Future<void> setLoggedInState(String email) async {
    emit(state.copyWith(isLoading: true));
    model_user user = await service_users.instance.getUserByEmail(email);
    if (user == null) return null;

    // Load groups
    List<model_group> joinedGroups = await service_groups.instance.getGroupsByIds(user.joinedGroupsIds);
    List<model_group> waitingGroups = await service_groups.instance.getGroupsByIds(user.waitingGroupsIds);

    // Set new state with logged in user details
    emit(state.copyWith(joinedGroups: joinedGroups, waitingGroups: waitingGroups, user: user, isLoading: false));
  }

  Future<void> reloadData() async {
    emit(state.copyWith(isLoading: true));

    // Load user & its groups
    model_user user = await service_users.instance.getUserByEmail(state.currentUser.email);
    List<model_group> joinedGroups = await service_groups.instance.getGroupsByIds(user.joinedGroupsIds);
    List<model_group> waitingGroups = await service_groups.instance.getGroupsByIds(user.waitingGroupsIds);

    emit(state.copyWith(joinedGroups: joinedGroups, waitingGroups: waitingGroups, user: user, isLoading: false));
  }

  void updateUser(model_user user) => emit(state.copyWith(user: user));

  void signOut() {
    emit(new state_app(isLoading: false));
  }
}
