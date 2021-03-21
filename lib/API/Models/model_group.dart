class model_group {
  // Keys
  static const KEY_COLLECTION_GROUPS = "groups";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_ICON_URL = "icon_url";
  static const KEY_CREATION_TIME = "creation_time";
  static const KEY_ADMIN_USERS = "admin_users";
  static const KEY_AUTO_JOIN = "auto_join";

  // Properties
  String id;
  String name;
  String icon_url;
  bool autoJoin;
  DateTime creation_time;
  List<String> admin_users_ids = [];

  model_group({this.id, this.name, this.icon_url, this.autoJoin});

  model_group.fromMap(Map<String, dynamic> data) {
    this.id = data[KEY_ID];
    this.name = data[KEY_NAME];
    this.icon_url = data[KEY_ICON_URL];
    this.autoJoin = data[KEY_AUTO_JOIN];
    this.creation_time = DateTime.parse(data[KEY_CREATION_TIME]).toLocal();
    this.admin_users_ids = List.castFrom(data[KEY_ADMIN_USERS]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      KEY_ID: this.id,
      KEY_NAME: this.name,
      KEY_ICON_URL: this.icon_url,
      KEY_AUTO_JOIN: this.autoJoin,
      KEY_ADMIN_USERS: this.admin_users_ids,
      KEY_CREATION_TIME: this.creation_time.toUtc().toString()
    };
    return data;
  }
}
