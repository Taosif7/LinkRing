import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';
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
                  model_group group = context.read<cubit_app>().state.groups[idx];
                  return ListTile(
                    title: Text(group.name, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400)),
                    leading: ProfileCircleAvatar.fromGroup(group),
                    trailing: Icon(CupertinoIcons.forward, color: Theme.of(context).primaryColor),
                    onTap: () => Navigator.push(context, LinkMessagesScreen.getRoute(context, group)),
                  );
                },
                shrinkWrap: true,
                itemCount: context.read<cubit_app>().state.groups.length);
        },
      ),
    );
  }
}
