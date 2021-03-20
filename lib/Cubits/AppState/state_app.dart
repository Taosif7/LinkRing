class state_app {
  bool isLoggedIn = false;

  state_app({bool this.isLoggedIn});

  state_app copyWith({bool isLoggedIn}) {
    state_app newState = new state_app(isLoggedIn: isLoggedIn ?? this.isLoggedIn);
    return newState;
  }
}
