import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/API/Services/service_links.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';

class cubit_linkMessagesScreen extends Cubit<state_linkMessagesScreen> {
  model_user currentUser;
  bool allLinksLoaded = false;
  List<model_member> senderMembers = [];

  cubit_linkMessagesScreen(state_linkMessagesScreen initialState, this.currentUser) : super(initialState) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    emit(state.copy(isLinksLoading: true, isMembersLoading: true));
    List<model_member> adminMembers = await service_members.instance.getMembersByIds(state.group.id, state.group.admin_users_ids);
    List<model_member> joinedMembers = await service_members.instance.getMembers(state.group.id);
    List<model_link> links = await service_links.instance.getLinksForGroup(state.group.id, senderMembers: senderMembers);

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
    List<model_link> links = await service_links.instance
        .getLinksForGroup(state.group.id, lastItemId: state.links.last.id, senderMembers: senderMembers);
    if (links.length == 0) allLinksLoaded = true;
    emit(state.addLinks(links).copy(isLinksLoading: false));
  }

  Future<void> removeAdmin(model_member member) async {
    await service_groups.instance.removeAdmin(state.group, member.id);
    state.adminMembers.removeWhere((admin) => admin.id == member.id);
    state.isAdmin = state.isAdmin && member.id != currentUser.id;
    emit(state.copy());
  }

  Future<void> addAdmin(model_member member) async {
    await service_groups.instance.addAdmin(state.group, member.id);
    state.adminMembers.add(member);
    emit(state.copy());
  }

  Future<void> admitMember(model_member member) async {
    await service_members.instance.admitMember(state.group.id, member.id);
    state.addJoinedMembers([member]);
    state.waitingMembers.removeWhere((element) => element.id == member.id);
    emit(state.copy());
  }

  Future<void> unAdmitMember(model_member member) async {
    await service_members.instance.unAdmitMember(state.group.id, member.id);
    state.addWaitingMembers([member]);
    state.joinedMembers.removeWhere((element) => element.id == member.id);
    if (state.group.admin_users_ids.contains(member.id)) await removeAdmin(member);
    emit(state.copy());
  }

  Future<void> removeMember(model_member member) async {
    await service_members.instance.removeMember(state.group.id, member.id);
    state.waitingMembers.removeWhere((element) => element.id == member.id);
    state.joinedMembers.removeWhere((element) => element.id == member.id);

    if (state.group.admin_users_ids.contains(member.id)) await removeAdmin(member);

    emit(state.copy());
  }
}
