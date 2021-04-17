import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/Utils/RegexPatterns.dart';

class ProfileCircleAvatar extends StatelessWidget {
  String text;
  String photoUrl;
  double size;

  ProfileCircleAvatar.fromMember(model_member member, {this.size = 20}) {
    this.photoUrl = member.profilePicUrl;
    this.text = member.name;
  }

  ProfileCircleAvatar.fromUser(model_user user, {this.size = 20}) {
    this.photoUrl = user.profile_pic_url;
    this.text = user.name;
  }

  ProfileCircleAvatar.fromGroup(model_group group, {this.size = 20}) {
    this.photoUrl = group.icon_url;
    this.text = group.name;
  }

  ProfileCircleAvatar.fromText(this.text, {this.size = 20});

  ProfileCircleAvatar.fromImageOrLabel(this.photoUrl, this.text, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    if (this.photoUrl != null && this.photoUrl.length > 0) {
      return CircleAvatar(backgroundImage: NetworkImage(photoUrl), maxRadius: size);
    } else if (RegexPatterns.emojis.firstMatch(this.text) != null) {
      this.text = RegexPatterns.emojis.stringMatch(text);
      return CircleAvatar(child: getGradientTextChild(this.text), maxRadius: size);
    } else if (this.text.trim().length >= 2) {
      String finalText;
      if (text.trim().contains(" "))
        finalText = text
            .trim()
            .split(RegExp(r'([ ]+)'))
            .reduce((value, element) => value.substring(0, 1).toUpperCase() + element.substring(0, 1).toUpperCase());
      else
        finalText = text.substring(0, 2).toUpperCase();
      text = finalText;
      return CircleAvatar(child: getGradientTextChild(this.text), maxRadius: size);
    } else
      return CircleAvatar(maxRadius: size, child: getGradientTextChild(""));
  }

  Widget getGradientTextChild(String text) {
    String hash = (text.hashCode + 200).toString();
    List<Color> gradientColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.amber,
      Colors.indigo,
      Colors.teal,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.deepPurpleAccent,
    ];
    int index1 = int.parse(hash[0]);
    int index2 = int.parse(hash[1]);

    return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [gradientColors[index1], gradientColors[index2]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
        height: double.infinity,
        width: double.infinity);
  }
}
