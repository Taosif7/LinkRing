class model_link {
  // Keys
  static const KEY_COLLECTION_LINKS = "links";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_LINK = "link";
  static const KEY_SENT_TIME = "sent_time";

  // properties
  String id;
  String name;
  String link;
  DateTime sent_time;

  model_link({this.id, this.name, this.link});

  model_link.fromMap(Map<String, dynamic> map) {
    id = map[KEY_ID];
    name = map[KEY_NAME];
    link = map[KEY_LINK];
    sent_time = DateTime.parse(map[KEY_SENT_TIME]).toLocal();
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[KEY_ID] = this.id;
    data[KEY_NAME] = this.name;
    data[KEY_LINK] = this.link;
    data[KEY_SENT_TIME] = this.sent_time.toUtc().toString();
    return data;
  }
}
