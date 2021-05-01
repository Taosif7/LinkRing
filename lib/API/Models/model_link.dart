import 'package:link_ring/API/Models/model_member.dart';

class model_link {
  // Keys
  static const KEY_COLLECTION_LINKS = "links";
  static const KEY_COLLECTION_ACKNOWLEDGEMENTS = "acknowledgements";
  static const KEY_ID = "id";
  static const KEY_NAME = "name";
  static const KEY_LINK = "link";
  static const KEY_SENT_TIME = "sent_time";
  static const KEY_SENT_BY = "sent_by";

  // properties
  String id;
  String name;
  String link;
  String sent_by;
  DateTime sent_time;
  model_member senderMember;

  model_link({this.id, this.name, this.link});

  model_link.fromMap(Map<String, dynamic> map) {
    id = map[KEY_ID];
    name = map[KEY_NAME];
    link = map[KEY_LINK];
    sent_time = DateTime.parse(map[KEY_SENT_TIME]).toLocal();
    sent_by = map[KEY_SENT_BY];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[KEY_ID] = this.id;
    data[KEY_NAME] = this.name;
    data[KEY_LINK] = this.link;
    data[KEY_SENT_TIME] = this.sent_time.toUtc().toString();
    data[KEY_SENT_BY] = this.sent_by;
    return data;
  }

  bool get hasName => this.name != null && this.name.trim().length > 0;
}
