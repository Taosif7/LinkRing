class model_user {
  // Keys
  static const KEY_COLLECTION_USERS = "users";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_EMAIL = "email";
  static const KEY_PROFILE_PIC = "profile_pic_url";
  static const KEY_MSG_TOKEN = "msg_token";
  static const KEY_JOIN_DATE = "join_date";
  static const KEY_GROUPS = "joined_groups";

  // Properties
  String id;
  String name;
  String profile_pic_url;
  String email;
  String msg_token;
  DateTime join_date;
  List<String> joinedGroupsIds = [];

  model_user(
      {this.id, this.name, this.email, this.msg_token, this.joinedGroupsIds = const [], this.join_date, this.profile_pic_url});

  model_user.fromMap(Map<String, dynamic> map) {
    this.id = map[KEY_ID];
    this.name = map[KEY_NAME];
    this.email = map[KEY_EMAIL];
    this.msg_token = map[KEY_MSG_TOKEN];
    this.profile_pic_url = map[KEY_PROFILE_PIC];
    this.join_date = DateTime.parse(map[KEY_JOIN_DATE]).toLocal();
    this.joinedGroupsIds = List.castFrom(map[KEY_GROUPS]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      KEY_ID: this.id,
      KEY_NAME: this.name,
      KEY_EMAIL: this.email.toLowerCase(),
      KEY_PROFILE_PIC: this.profile_pic_url,
      KEY_MSG_TOKEN: this.msg_token,
      KEY_JOIN_DATE: this.join_date.toUtc().toString(),
      KEY_GROUPS: this.joinedGroupsIds
    };

    return data;
  }
}
