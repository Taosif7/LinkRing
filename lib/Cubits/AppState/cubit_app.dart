import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';

class cubit_app extends Cubit<state_app> {
  cubit_app(state_app initialState) : super(initialState) {
    // Check if logged in
    if (FirebaseAuth.instance.currentUser != null)
      setLoggedInState(FirebaseAuth.instance.currentUser.email);
    else
      emit(state.copyWith(isLoggedIn: false, isLoading: false));
  }

  Future<void> setLoggedInState(String email) async {
    emit(state.copyWith(isLoading: true));
    model_user user = await service_users.instance.getUserByEmail(email);
    if (user == null) return null;

    // Load groups
    List<model_group> joinedGroups = await service_groups.instance.getGroupsByIds(user.joinedGroupsIds);

    emit(state.copyWith(isLoggedIn: true, joinedGroups: joinedGroups, user: user, isLoading: false));
  }

  void signOut() {
    emit(new state_app(isLoggedIn: false));
  }
}
