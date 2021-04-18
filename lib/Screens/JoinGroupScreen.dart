import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:shimmer/shimmer.dart';

class JoinGroupScreen extends StatefulWidget {
  final String groupId;

  JoinGroupScreen({Key key, this.groupId}) : super(key: key);

  @override
  _JoinGroupScreenState createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  Future groupJoin;
  model_group group;
  model_member member;
  String message;
  String ctaLabel;
  void Function() ctaCallback;

  @override
  void initState() {
    groupJoin = new Future(() async {
      // Load group & display info
      group = await service_groups.instance.getGroupById(widget.groupId);
      setState(() {});
      if (group == null) {
        message = "Group not found!";
        ctaLabel = "Okay";
        ctaCallback = () => Navigator.of(context).pop();
        return;
      }

      // Wait until user details are loaded in the app state
      // Check with exponential back-off strategy
      model_user currentUser = context.read<cubit_app>().state.currentUser;
      await Future.forEach([1, 2, 3], (element) async {
        if (currentUser == null) {
          await Future.delayed(
              Duration(milliseconds: element * 500), () => currentUser = context.read<cubit_app>().state.currentUser);
        }
      });

      // If details are not loaded even after loop, display user about it
      if (currentUser == null) {
        message = "Something went wrong";
        ctaLabel = "Okay";
        ctaCallback = () => Navigator.of(context).pop();
        setState(() {});
        return;
      }

      // Check if already member
      member = await service_members.instance.getMemberById(group.id, currentUser.id);
      if (member != null) {
        // Handle cases like already-joined, waiting, banned, etc
        if (!member.isJoined) {
          message = "You are in the waiting list";
          ctaLabel = "Okay";
          ctaCallback = () => Navigator.of(context).pop();
        } else {
          message = "You are already a member of this group";
          ctaLabel = "Open Group";
          ctaCallback = () => Navigator.of(context).pushReplacementNamed('group/${group.id}');
        }
      } else {
        // Join the member to group
        await service_members.instance.addMember(group.id, new model_member.fromUser(currentUser, group.autoJoin));
        if (group.autoJoin)
          await service_users.instance.addJoinedGroupId(currentUser.id, group.id);
        else
          await service_users.instance.addWaitingGroupId(currentUser.id, group.id);

        // Reload app data
        await context.read<cubit_app>().reloadData();

        if (group.autoJoin) {
          message = "You joined the group!";
          ctaLabel = "Open Group";
          ctaCallback = () => Navigator.of(context).pushReplacementNamed('group/${group.id}/');
        } else {
          message = "You are added to the waiting list";
          ctaLabel = "Okay";
          ctaCallback = () => Navigator.of(context).pop();
        }
      }

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join group")),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
        child: Column(
          children: [
            if (group != null) ...[
              ProfileCircleAvatar.fromGroup(group, size: 30),
              SizedBox(height: 10),
              Text(group.name, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold)),
            ] else ...[
              Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade50,
                  child: ProfileCircleAvatar.fromText("text", size: 30)),
              SizedBox(height: 10),
              Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade50,
                  child:
                      Text("••••••••••••••", style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold))),
            ],
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (message == null) ...[
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Joining group..."),
                ] else ...[
                  Text(message, style: Theme.of(context).textTheme.headline5),
                ],
                if (ctaLabel != null && ctaCallback != null) TextButton(onPressed: ctaCallback, child: Text(ctaLabel))
              ],
            )),
          ],
        ),
      ),
    );
  }
}
