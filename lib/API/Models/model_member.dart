import 'package:link_ring/API/Models/model_user.dart';

class model_member {
  // Keys
  static const KEY_COLLECTION_MEMBERS = "members";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_EMAIL = "email";
  static const KEY_PROFILE_PIC = "profilePicUrl";
  static const KEY_JOINED_TIME = "joined_on";

  String id;
  String email;
  String name;
  String profilePicUrl;
  DateTime joined;

  model_member({this.id, this.email, this.name, this.joined, this.profilePicUrl});

  model_member.fromUser(model_user user) {
    this.id = user.id;
    this.email = user.email;
    this.name = user.name;
    this.profilePicUrl = user.profile_pic_url;
  }

  model_member.fromJson(Map<String, dynamic> json) {
    id = json[KEY_ID];
    email = json[KEY_EMAIL];
    name = json[KEY_NAME];
    profilePicUrl = json[KEY_PROFILE_PIC];
    joined = DateTime.parse(json[KEY_JOINED_TIME]).toLocal();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[KEY_ID] = this.id;
    data[KEY_EMAIL] = this.email;
    data[KEY_NAME] = this.name;
    data[KEY_PROFILE_PIC] = this.profilePicUrl;
    data[KEY_JOINED_TIME] = this.joined?.toUtc()?.toString();
    return data;
  }
}
