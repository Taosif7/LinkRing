import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/Utils/RegexPatterns.dart';

class ProfileCircleAvatar extends StatelessWidget {
  model_member member;
  model_user user;
  String text;
  double size;

  ProfileCircleAvatar.fromMember(this.member, {this.size = 20});

  ProfileCircleAvatar.fromUser(this.user, {this.size = 20});

  ProfileCircleAvatar.fromText(this.text, {this.size = 20}) {
    this.text = this.text.trim();
    if (RegexPatterns.emojis.firstMatch(this.text) != null)
      this.text = RegexPatterns.emojis.stringMatch(this.text);
    else if (this.text.length >= 2) {
      String finalText = text.substring(0, 2);
      if (text.contains(" "))
        finalText = text
            .split(" ")
            .reduce((value, element) => value.substring(0, 1).toUpperCase() + element.substring(0, 1).toUpperCase());
      text = finalText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text != null && text.length >= 2) {
      return CircleAvatar(child: Text(text), maxRadius: size);
    } else if (user != null) {
      return CircleAvatar(backgroundImage: NetworkImage(user.profile_pic_url), maxRadius: size);
    } else if (member != null) {
      return CircleAvatar(backgroundImage: NetworkImage(member.profilePicUrl), maxRadius: size);
    } else
      return CircleAvatar(maxRadius: size);
  }
}
