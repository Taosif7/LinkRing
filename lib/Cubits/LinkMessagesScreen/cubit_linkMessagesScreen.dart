import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_links.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';

class cubit_linkMessagesScreen extends Cubit<state_linkMessagesScreen> {
  model_user currentUser;
  bool allLinksLoaded = false;

  cubit_linkMessagesScreen(state_linkMessagesScreen initialState, this.currentUser) : super(initialState) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    emit(state.copy(isLinksLoading: true, isMembersLoading: true));
    List<model_link> links = await service_links.instance.getLinksForGroup(state.group.id);
    List<model_member> adminMembers = await service_members.instance.getMembersByIds(state.group.id, state.group.admin_users_ids);
    List<model_member> joinedMembers = await service_members.instance.getMembers(state.group.id);

    // Load waiting list members only if current user is admin
    bool isAdmin = state.group.admin_users_ids.contains(currentUser.id);
    List<model_member> waitingMembers;
    if (isAdmin) waitingMembers = await service_members.instance.getMembers(state.group.id, joined: false);

    emit(state.copy(
      isLinksLoading: false,
      isMembersLoading: false,
      links: links,
      isAdmin: isAdmin,
      adminMembers: adminMembers,
      joinedMembers: joinedMembers,
      waitingMembers: waitingMembers,
    ));
  }

  Future<void> loadMoreLinks() async {
    if (allLinksLoaded) return;
    emit(state.copy(isLinksLoading: true));
    List<model_link> links = await service_links.instance.getLinksForGroup(state.group.id, lastItemId: state.links.last.id);
    if (links.length == 0) allLinksLoaded = true;
    emit(state.addLinks(links).copy(isLinksLoading: false));
  }
}
