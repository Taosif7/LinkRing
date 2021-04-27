import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/cubit_linkMessagesScreen.dart';
import 'package:link_ring/Screens/Commons/Buttons.dart';
import 'package:link_ring/Screens/Commons/CupertinoBackButton.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
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
          child: BuildMembersContainer(context, "Admins", context.read<cubit_linkMessagesScreen>().state.adminMembers, () {}),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        SliverToBoxAdapter(
          child: BuildMembersContainer(context, "Members", context.read<cubit_linkMessagesScreen>().state.joinedMembers, () {}),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        if (context.read<cubit_linkMessagesScreen>().state.isAdmin)
          SliverToBoxAdapter(
            child: BuildMembersContainer(
                context, "Waiting List", context.read<cubit_linkMessagesScreen>().state.waitingMembers, () {}),
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
              onPressed: () {},
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
