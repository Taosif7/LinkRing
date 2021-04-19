import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/cubit_linkMessagesScreen.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';
import 'package:link_ring/Screens/Commons/CupertinoBackButton.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/GroupInfoScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/widgets/LinkMessageItem.dart';

class LinkMessagesScreen extends StatelessWidget {
  model_group group;

  LinkMessagesScreen(this.group);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5,
        title: InkWell(
          onTap: () => Navigator.push(context, GroupInfoScreen.getRoute(context, group)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            child: Row(
              children: [
                Hero(tag: 'GroupPicture' + group.id, child: ProfileCircleAvatar.fromGroup(group, size: 18)),
                SizedBox(width: 10),
                Text(group.name),
              ],
            ),
          ),
        ),
        leading: CupertinoBackIconButton(),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {},
          )
        ],
      ),
      body: Column(children: [
        BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (loadingCtx, state) {
          if (state.isLinksLoading)
            return Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(child: CircularProgressIndicator(strokeWidth: 3), height: 20, width: 20),
            ));
          else
            return Container();
        }),
        Expanded(child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (linksViewCtx, state) {
          if (!state.isLinksLoading && state.links.length == 0) {
            return Center(child: Text("No Links"));
          } else
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemBuilder: (itemBuilderCtx, index) => LinkMessageItem(state.links[index]),
              reverse: true,
              itemCount: state.links.length,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            );
        })),
        Container(
          height: 60,
          color: Colors.red.shade100,
          child: Center(
            child: Text("Reserved for Toolbox for Sending Links"),
          ),
        ),
      ]),
    );
  }

  static CupertinoPageRoute getRoute(BuildContext context, model_group group, {bool disableTransition = false}) {
    return new CupertinoPageRoute(
        builder: (x) => BlocProvider(
            create: (c) => cubit_linkMessagesScreen(state_linkMessagesScreen(group), context.read<cubit_app>().state.currentUser),
            child: LinkMessagesScreen(group)),
        settings: RouteSettings(name: 'group/${group.id}'));
  }
}
