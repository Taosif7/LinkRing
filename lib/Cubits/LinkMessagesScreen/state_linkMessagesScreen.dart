import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';

class state_linkMessagesScreen {
  // Data members
  List<model_link> links;
  List<model_member> members;
  model_group group;

  // Flags
  bool isLinksLoading;
  bool isMembersLoading;

  state_linkMessagesScreen(this.group,
      {this.links = const [], this.members = const [], this.isLinksLoading = false, this.isMembersLoading = false});

  state_linkMessagesScreen addLinks(List<model_link> moreLinks) {
    this.links.addAll(moreLinks);
    return this;
  }

  state_linkMessagesScreen addMembers(List<model_member> moreMembers) {
    this.members.addAll(moreMembers);
    return this;
  }

  state_linkMessagesScreen copy(
      {model_group group, List<model_link> links, List<model_member> members, bool isLinksLoading, bool isMembersLoading}) {
    return new state_linkMessagesScreen(
      group ?? this.group,
      links: links ?? this.links,
      members: members ?? this.members,
      isLinksLoading: isLinksLoading ?? this.isLinksLoading,
      isMembersLoading: isMembersLoading ?? this.isMembersLoading,
    );
  }
}
