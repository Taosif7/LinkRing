import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/cubit_linkMessagesScreen.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';
import 'package:link_ring/Screens/Commons/Buttons.dart';
import 'package:link_ring/Screens/Commons/CupertinoBackButton.dart';
import 'package:link_ring/Screens/Commons/IndefiniteProgressScreen.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Screens/MemberListScreen.dart';
import 'package:link_ring/Utils/DateFormatConstants.dart';

class GroupInfoScreen extends StatelessWidget {
  final model_group group;

  GroupInfoScreen({Key key, this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          leading: CupertinoBackIconButton(),
          expandedHeight: ((group.icon_url?.length ?? 0) > 0) ? 300 : 150,
          stretch: true,
          title: Text(group.name),
          excludeHeaderSemantics: true,
          stretchTriggerOffset: 150,
          pinned: true,
          titleSpacing: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'GroupPicture' + group.id,
              transitionOnUserGestures: true,
              child: Container(
                decoration:
                    BoxDecoration(gradient: ProfileCircleAvatar.getGradient(ProfileCircleAvatar.getLabelText(group.name))),
                child: ((group.icon_url?.length ?? 0) > 0) ? Image.network(group.icon_url, fit: BoxFit.cover) : null,
              ),
            ),
            collapseMode: CollapseMode.pin,
            stretchModes: [StretchMode.zoomBackground],
          ),
        ),
        SliverToBoxAdapter(
            child: Container(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Information", style: Theme.of(context).textTheme.subtitle2),
                    SizedBox(height: 10),
                    Text("Started on: " + DateTimeDayFormat.format(group.creation_time)),
                  ],
                ))),
        SliverToBoxAdapter(
          child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(
            builder: (ctx, state) => BuildMembersContainer(context, "Admins", state.adminMembers, () {
              Navigator.of(context).push(new CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => new MemberListScreen(
                        "Admins",
                        state.adminMembers,
                        buttons: state.isAdmin
                            ? [
                                {
                                  "Remove admin": (member) {
                                    if (state.group.admin_users_ids.length == 1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Can't remove only admin of group")));
                                      return false;
                                    } else {
                                      context.read<cubit_linkMessagesScreen>().removeAdmin(member);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Removed from admin")));
                                      return true;
                                    }
                                  }
                                },
                              ]
                            : [],
                      )));
            }),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        SliverToBoxAdapter(
          child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(
            builder: (ctx, state) => BuildMembersContainer(context, "Members", state.joinedMembers, () {
              Navigator.of(context).push(new CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => new MemberListScreen(
                        "Joined members",
                        state.joinedMembers,
                        hideActionsForMembers: [context.read<cubit_linkMessagesScreen>().currentUser.id],
                        onSearch: (query) => service_members.instance.searchMemberByName(group.id, query),
                        buttons: state.isAdmin
                            ? [
                                {
                                  "Make admin": (member) {
                                    if (state.group.admin_users_ids.contains(member.id)) {
                                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Already an admin")));
                                    } else {
                                      context.read<cubit_linkMessagesScreen>().addAdmin(member);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Promoted to admin")));
                                    }
                                    return false;
                                  }
                                },
                                {
                                  "Un-Admit": (member) {
                                    if (state.group.admin_users_ids.contains(member.id) &&
                                        state.group.admin_users_ids.length == 1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Can't remove only admin of group")));
                                      return false;
                                    } else {
                                      context.read<cubit_linkMessagesScreen>().unAdmitMember(member);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Moved to waiting list")));
                                      return true;
                                    }
                                  }
                                },
                                {
                                  "Delete": (member) {
                                    if (state.group.admin_users_ids.contains(member.id) &&
                                        state.group.admin_users_ids.length == 1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Can't remove only admin of group")));
                                      return false;
                                    } else {
                                      context.read<cubit_linkMessagesScreen>().removeMember(member);
                                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Member removed")));
                                      return true;
                                    }
                                  }
                                },
                              ]
                            : [],
                      )));
            }),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        if (context.read<cubit_linkMessagesScreen>().state.isAdmin)
          SliverToBoxAdapter(
            child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(
              builder: (ctx, state) => BuildMembersContainer(context, "Waiting list", state.waitingMembers, () {
                Navigator.of(context).push(new CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (ctx) => new MemberListScreen(
                          "Waiting List",
                          state.waitingMembers,
                          hideActionsForMembers: [context.read<cubit_linkMessagesScreen>().currentUser.id],
                          onSearch: (query) => service_members.instance.searchMemberByName(group.id, query),
                          buttons: state.isAdmin
                              ? [
                                  {
                                    "Admit": (member) {
                                      context.read<cubit_linkMessagesScreen>().admitMember(member);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(new SnackBar(content: Text("Member joined the group")));
                                      return true;
                                    }
                                  },
                                  {
                                    "Delete": (member) {
                                      context.read<cubit_linkMessagesScreen>().removeAdmin(member);
                                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Member removed")));
                                      return true;
                                    }
                                  },
                                ]
                              : [],
                        )));
              }),
            ),
          ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ColorButton(
              color: Colors.blueAccent,
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: "http://LinkRing.Taosif7.com/joingroup?id=" + group.id));
                ScaffoldMessenger.of(context)
                    .showSnackBar(new SnackBar(content: Text("Link Copied"), behavior: SnackBarBehavior.floating));
              },
              label: 'Invite People',
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: ColorButton(
              color: Colors.redAccent,
              onPressed: () async {
                if (context.read<cubit_linkMessagesScreen>().state.isAdmin &&
                    context.read<cubit_linkMessagesScreen>().state.group.admin_users_ids.length == 1) {
                  ScaffoldMessenger.maybeOf(context)
                      .showSnackBar(new SnackBar(content: Text("Can't leave group as you're the only admin")));
                  return;
                }

                // Ask for confirmation
                bool confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) {
                      return new AlertDialog(
                        title: Text("Do you really want to leave?"),
                        actions: [
                          TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true)),
                          TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false)),
                        ],
                      );
                    });
                if (!confirm) return;

                showIndefiniteProgressScreen(context);
                await context.read<cubit_linkMessagesScreen>().leaveGroup();
                await context.read<cubit_app>().reloadData();
                hideIndefiniteProgressScreen(context);
                ScaffoldMessenger.maybeOf(context).showSnackBar(new SnackBar(content: Text("You left the group")));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              label: 'Leave Group',
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 300)),
      ]),
    );
  }

  Widget BuildMembersContainer(BuildContext context, String label, List<model_member> members, Function onTapMore) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(children: [
          Text(label, style: Theme.of(context).textTheme.subtitle2),
          SizedBox(height: 10),
          if (members.length > 0)
            Wrap(children: [
              ...List.generate(
                  members.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ProfileCircleAvatar.fromMember(members[index]),
                      )),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                tooltip: "View All",
                onPressed: onTapMore,
              )
            ], crossAxisAlignment: WrapCrossAlignment.center)
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text("No Members"),
            )
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }

  static CupertinoPageRoute getRoute(BuildContext context, model_group group) {
    return new CupertinoPageRoute(
        builder: (x) =>
            BlocProvider(create: (c) => context.read<cubit_linkMessagesScreen>(), child: GroupInfoScreen(group: group)),
        settings: RouteSettings(name: 'group/${group.id}/info'));
  }
}
