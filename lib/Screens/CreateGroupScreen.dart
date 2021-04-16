import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/IndefiniteProgressScreen.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Utils/TextValidator.dart';

class Screen_CreateGroup extends StatefulWidget {
  @override
  _Screen_CreateGroupState createState() => _Screen_CreateGroupState();
}

class _Screen_CreateGroupState extends State<Screen_CreateGroup> {
  TextEditingController _groupNameController = new TextEditingController();
  bool autoJoin = true;
  String groupNameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create new group")),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Create Group"),
          onPressed: () async {
            if (!TextValidator.validate(_groupNameController.text, [TextValidator.VALIDATOR_START_ALPHANUMERIC], minLength: 6)) {
              return setState(() => groupNameError = "Name not valid");
            } else if (_groupNameController.text.length < 6) {
              return setState(() => groupNameError = "Group name too short");
            }

            showIndefiniteProgressScreen(context);

            // Create group
            model_group newGroup = new model_group(name: _groupNameController.text, autoJoin: autoJoin, icon_url: "");
            newGroup = await service_groups.instance.createGroup(newGroup, context.read<cubit_app>().state.currentUser);

            // Add this info to user
            context.read<cubit_app>().reloadData();

            hideIndefiniteProgressScreen(context);
            Navigator.pop(context);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5),
                child: ProfileCircleAvatar.fromText(_groupNameController.text.length != 0 ? _groupNameController.text : "😋",
                    size: 30),
              ),
              SizedBox(
                height: 30,
                width: 30,
                child: Container(
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // TODO : Show option to set or clear group picture
                    },
                    iconSize: 15,
                    padding: EdgeInsets.zero,
                  ),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              )
            ],
            alignment: Alignment.topRight,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _groupNameController,
              onChanged: (s) {
                setState(() {
                  if (!TextValidator.validate(_groupNameController.text, [TextValidator.VALIDATOR_START_ALPHANUMERIC]))
                    groupNameError = "Name not valid";
                  else if (_groupNameController.text.length < 6)
                    groupNameError = "Group name too short";
                  else
                    groupNameError = null;
                });
              },
              maxLength: 30,
              maxLines: 1,
              decoration: InputDecoration(hintText: "Group Name", errorText: groupNameError),
            ),
          ),
          RadioListTile<bool>(
            value: true,
            groupValue: autoJoin,
            onChanged: (v) => setState(() => autoJoin = v),
            title: Text("Public", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Let anyone join via invite link"),
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: Container(
              child: Icon(Icons.public, color: Theme.of(context).iconTheme.color),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Divider(height: 2, indent: 80, endIndent: 20),
          RadioListTile<bool>(
            value: false,
            groupValue: autoJoin,
            onChanged: (v) => setState(() => autoJoin = v),
            title: Text("Private", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Users need approval for joining"),
            controlAffinity: ListTileControlAffinity.trailing,
            secondary: Container(
              child: Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 60),
        ]),
      ),
    );
  }
}
