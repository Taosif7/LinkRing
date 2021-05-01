import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';
import 'package:link_ring/Screens/Commons/IndefiniteProgressScreen.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/LinkMessagesScreen.dart';

class Screen_HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Link Ring"),
        actions: [
          BlocBuilder<cubit_app, state_app>(
            builder: (ctx, state) {
              return IconButton(
                  icon: ProfileCircleAvatar.fromImageOrLabel(
                    (state.isLoading) ? null : context.read<cubit_app>().state.currentUser.profile_pic_url,
                    (state.isLoading) ? "" : context.read<cubit_app>().state.currentUser.name,
                    size: (state.isLoading) ? 5 : 20,
                  ),
                  onPressed: () {
                    // TODO : Open options menu
                  });
            },
          ),
          PopupMenuButton(
            itemBuilder: (c) {
              return [
                PopupMenuItem(
                    child: ListTile(
                        title: Text("New group"), leading: Icon(Icons.add), contentPadding: EdgeInsets.zero, dense: true),
                    value: 1),
                PopupMenuItem(child: PopupMenuDivider(height: 2), height: 1, enabled: false),
                PopupMenuItem(
                    child: ListTile(
                        title: Text("Logout"), leading: Icon(Icons.logout), contentPadding: EdgeInsets.zero, dense: true),
                    value: 2),
              ];
            },
            icon: Icon(Icons.more_vert),
            onSelected: (v) {
              switch (v) {
                case 1:
                  Navigator.pushNamed(context, 'createGroup');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, 'logout');
                  context.read<cubit_app>().auth.signOut(context);
                  break;
              }
            },
          )
        ],
      ),
      body: BlocBuilder<cubit_app, state_app>(
        builder: (ctx, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else
            return ListView.builder(
                itemBuilder: (ctx, idx) {
                  if (idx == 0)
                    return Container(
                      color: Colors.blueGrey.withAlpha(30),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text("Joined groups"),
                    );

                  if (idx == context.read<cubit_app>().state.groups.length + 1)
                    return Container(
                      color: Colors.blueGrey.withAlpha(30),
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text("Requested to join"),
                    );

                  if (idx < context.read<cubit_app>().state.groups.length + 1) {
                    model_group group = context.read<cubit_app>().state.groups[idx - 1];
                    return ListTile(
                      title: Text(group.name, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400)),
                      leading: ProfileCircleAvatar.fromGroup(group),
                      tileColor: idx % 2 == 0 ? Colors.blueGrey.withAlpha(15) : Colors.transparent,
                      trailing: Icon(CupertinoIcons.forward, color: Theme.of(context).primaryColor),
                      onTap: () => Navigator.push(context, LinkMessagesScreen.getRoute(context, group)),
                    );
                  } else {
                    model_group group =
                        context.read<cubit_app>().state.waitingGroups[idx - context.read<cubit_app>().state.groups.length - 2];
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: Colors.redAccent,
                        alignment: Alignment.centerLeft,
                        height: 100,
                        child: Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      key: Key(idx.toString()),
                      onDismissed: (direction) async {
                        showIndefiniteProgressScreen(context);
                        await service_users.instance
                            .removeWaitingGroupId(context.read<cubit_app>().state.currentUser.id, group.id);
                        service_members.instance.removeMember(group.id, context.read<cubit_app>().state.currentUser.id);
                        await context.read<cubit_app>().reloadData();
                        hideIndefiniteProgressScreen(context);
                      },
                      confirmDismiss: (direction) => showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) {
                            return new AlertDialog(
                              title: Text("Do you really want to cancel the request?"),
                              actions: [
                                TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true)),
                                TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false)),
                              ],
                            );
                          }),
                      child: ListTile(
                        title:
                            Text(group.name, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400)),
                        leading: ProfileCircleAvatar.fromGroup(group),
                        tileColor: idx % 2 == 0 ? Colors.blueGrey.withAlpha(15) : Colors.transparent,
                      ),
                    );
                  }
                },
                shrinkWrap: true,
                itemCount:
                    context.read<cubit_app>().state.groups.length + context.read<cubit_app>().state.waitingGroups.length + 2);
        },
      ),
    );
  }
}
