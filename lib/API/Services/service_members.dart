import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';

class service_members {
  static service_members service_instance;
  FirebaseFirestore firestore;

  service_members._() {
    firestore = FirebaseFirestore.instance;
  }

  get instance => service_instance ??= service_members._();

  Future<List<model_member>> getMembers(String groupId, {int quantity = 20, String afterThisId}) async {
    DocumentSnapshot prevDoc;
    if (afterThisId != null)
      prevDoc = await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .doc(groupId)
          .collection(model_member.KEY_COLLECTION_MEMBERS)
          .doc(afterThisId)
          .get();
    QuerySnapshot query = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .limit(quantity)
        .startAfterDocument(prevDoc)
        .orderBy(model_member.KEY_NAME)
        .get();

    List<model_member> members = [];
    query.docs.forEach((doc) => members.add(new model_member.fromJson(doc.data())));

    return members;
  }
}
