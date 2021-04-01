import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';

class cubit_app extends Cubit<state_app> {
  cubit_app(state_app initialState) : super(initialState);

  void setLoggedInState(model_user user, List<model_group> joinedGroups) {
    emit(state.copyWith(isLoggedIn: true, joinedGroups: joinedGroups, user: user));
  }

  void signOut() {
    emit(new state_app(isLoggedIn: false));
  }
}
