import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';

class GroupPickerScreen extends StatelessWidget {
  Future<List<model_group>> loadGroups;
  BuildContext context;
  bool showOnlyOwnedGroups = false;

  GroupPickerScreen(this.context, {this.showOnlyOwnedGroups = false}) {
    loadGroups = Future(() async {
      // Wait until user details are loaded in the app state
      // Check with exponential back-off strategy
      model_user currentUser = context.read<cubit_app>().state.currentUser;
      await Future.forEach([1, 2, 3], (element) async {
        if (currentUser == null) {
          await Future.delayed(
              Duration(milliseconds: element * 500), () => currentUser = context.read<cubit_app>().state.currentUser);
        }
      });

      String userId = context.read<cubit_app>().state.currentUser.id;
      List<model_group> allGroups = context.read<cubit_app>().state.groups;
      List<model_group> adminGroups = allGroups.where((element) => element.admin_users_ids.contains(userId)).toList();

      return adminGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a group")),
      body: FutureBuilder<List<model_group>>(
        future: loadGroups,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<model_group> groups = snapshot.data;
            if (!snapshot.hasData || snapshot.data.length == 0) {
              return Center(child: Text("No groups available"));
            } else
              return ListView.builder(
                  itemBuilder: (itemCtx, index) {
                    model_group group = groups[index];
                    return ListTile(
                      leading: ProfileCircleAvatar.fromGroup(group),
                      title: Text(group.name),
                      onTap: () => Navigator.of(context).pop(group),
                    );
                  },
                  itemCount: groups.length);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  static CupertinoPageRoute getRoute(BuildContext context, {bool showOnlyOwnedGroups = false}) {
    return new CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (x) => BlocProvider(
            create: (c) => context.read<cubit_app>(),
            child: GroupPickerScreen(context, showOnlyOwnedGroups: showOnlyOwnedGroups)),
        settings: RouteSettings(name: 'sendLink'));
  }
}
