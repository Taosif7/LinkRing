import 'package:link_ring/API/Models/model_user.dart';

class model_member {
  // Keys
  static const KEY_COLLECTION_MEMBERS = "members";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_EMAIL = "email";
  static const KEY_PROFILE_PIC = "profilePicUrl";
  static const KEY_JOINED_TIME = "joined_on";
  static const KEY_IS_JOINED = "is_joined";
  static const KEY_PUSH_TOKEN = "push_token";
  static const KEY_SILENT = "silent";

  String id;
  String email;
  String name;
  String profilePicUrl;
  DateTime joinedOn;
  bool isJoined;
  bool isSilent;
  String pushToken;

  model_member({this.id, this.email, this.name, this.joinedOn, this.profilePicUrl, this.isJoined, this.isSilent});

  model_member.fromUser(model_user user, bool isJoined) {
    this.id = user.id;
    this.email = user.email;
    this.name = user.name;
    this.profilePicUrl = user.profile_pic_url;
    this.isJoined = isJoined;
    this.pushToken = user.msg_token;
    this.isSilent = false;
  }

  model_member.fromJson(Map<String, dynamic> json) {
    id = json[KEY_ID];
    email = json[KEY_EMAIL];
    name = json[KEY_NAME];
    profilePicUrl = json[KEY_PROFILE_PIC];
    joinedOn = DateTime.parse(json[KEY_JOINED_TIME]).toLocal();
    isJoined = json[KEY_IS_JOINED] ?? true;
    pushToken = json[KEY_PUSH_TOKEN];
    isSilent = json[KEY_SILENT] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[KEY_ID] = this.id;
    data[KEY_EMAIL] = this.email;
    data[KEY_NAME] = this.name;
    data[KEY_PROFILE_PIC] = this.profilePicUrl;
    data[KEY_JOINED_TIME] = this.joinedOn?.toUtc()?.toString();
    data[KEY_IS_JOINED] = this.isJoined;
    data[KEY_PUSH_TOKEN] = this.pushToken;
    data[KEY_SILENT] = this.isSilent;
    return data;
  }
}
