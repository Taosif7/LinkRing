import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';

class state_linkMessagesScreen {
  // Data members
  List<model_link> links;
  List<model_member> joinedMembers;
  List<model_member> waitingMembers;
  List<model_member> adminMembers;
  bool isAdmin;
  bool isSilent;
  model_group group;

  // Flags
  bool isLinksLoading;
  bool isMembersLoading;

  state_linkMessagesScreen(this.group,
      {this.links = const [],
      this.joinedMembers = const [],
      this.waitingMembers = const [],
      this.adminMembers = const [],
      this.isLinksLoading = false,
      this.isAdmin = false,
      this.isSilent = false,
      this.isMembersLoading = false});

  state_linkMessagesScreen addLinks(List<model_link> moreLinks) {
    this.links.addAll(moreLinks);
    return this;
  }

  state_linkMessagesScreen addJoinedMembers(List<model_member> moreMembers) {
    this.joinedMembers.addAll(moreMembers);
    return this;
  }

  state_linkMessagesScreen addWaitingMembers(List<model_member> moreMembers) {
    this.waitingMembers.addAll(moreMembers);
    return this;
  }

  state_linkMessagesScreen addAdminMembers(List<model_member> moreMembers) {
    this.adminMembers.addAll(moreMembers);
    return this;
  }

  state_linkMessagesScreen copy(
      {model_group group,
      List<model_link> links,
      List<model_member> joinedMembers,
      List<model_member> waitingMembers,
      List<model_member> adminMembers,
      bool isLinksLoading,
      bool isAdmin,
      bool isSilent,
      bool isMembersLoading}) {
    return new state_linkMessagesScreen(
      group ?? this.group,
      links: links ?? this.links,
      joinedMembers: joinedMembers ?? this.joinedMembers,
      waitingMembers: waitingMembers ?? this.waitingMembers,
      adminMembers: adminMembers ?? this.adminMembers,
      isAdmin: isAdmin ?? this.isAdmin,
      isLinksLoading: isLinksLoading ?? this.isLinksLoading,
      isSilent: isSilent ?? this.isSilent,
      isMembersLoading: isMembersLoading ?? this.isMembersLoading,
    );
  }
}
