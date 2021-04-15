import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';

class ProfileCircleAvatar extends StatelessWidget {
  model_member member;
  model_user user;
  String text;
  double size;

  ProfileCircleAvatar.fromMember(this.member, {this.size = 20});

  ProfileCircleAvatar.fromUser(this.user, {this.size = 20});

  ProfileCircleAvatar.fromText(this.text, {this.size = 20}) {
    this.text = this.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (text != null && text.length >= 2) {
      String label = text.substring(0, 2);
      if (text.contains(" "))
        label = text
            .split(" ")
            .reduce((value, element) => value.substring(0, 1).toUpperCase() + element.substring(0, 1).toUpperCase());
      return CircleAvatar(child: Text(label), maxRadius: size);
    } else if (user != null) {
      return CircleAvatar(backgroundImage: NetworkImage(user.profile_pic_url), maxRadius: size);
    } else if (member != null) {
      return CircleAvatar(backgroundImage: NetworkImage(member.profilePicUrl), maxRadius: size);
    } else
      return CircleAvatar(maxRadius: size);
  }
}
