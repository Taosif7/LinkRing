import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Services/service_links.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';

class cubit_linkMessagesScreen extends Cubit<state_linkMessagesScreen> {
  cubit_linkMessagesScreen(state_linkMessagesScreen initialState) : super(initialState) {
    loadLinksAndMembers();
  }

  Future<void> loadLinksAndMembers() async {
    emit(state.copy(isLinksLoading: true, isMembersLoading: true));
    List<model_link> links = await service_links.instance.getLinksForGroup(state.group.id);
    List<model_member> members = await service_members.instance.getMembers(state.group.id);
    emit(state.copy(isLinksLoading: false, isMembersLoading: false, links: links, members: members));
  }
}
