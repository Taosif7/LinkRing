import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_ring/API/Models/model_group.dart';

class service_groups {
  static service_groups service_instance;
  FirebaseFirestore firestore;

  service_groups._() {
    firestore = FirebaseFirestore.instance;
  }

  get instance => service_instance ??= service_groups._();

  Future<model_group> getGroupById(String id) async {
    DocumentSnapshot doc = await firestore.collection(model_group.KEY_COLLECTION_GROUPS).doc(id).get();
    return model_group.fromMap(doc.data());
  }

  Future<List<model_group>> getGroupsByIds(List<String> groupIds) async {
    List<model_group> groups = [];

    // for every 10 elements, perform where in query to find groups
    for (int i = 0; i < groupIds.length; i += 10) {
      QuerySnapshot qs = await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .where(model_group.KEY_ID,
              whereIn: groupIds.sublist(i, (i + 10 >= groupIds.length) ? groupIds.length - 1 : i + 10).toList())
          .get();
      qs.docs.forEach((doc) => groups.add(model_group.fromMap(doc.data())));
    }

    return groups;
  }
}
