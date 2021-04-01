import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_ring/API/Models/model_user.dart';

class service_users {
  static service_users _service_instance;
  FirebaseFirestore firestore;

  service_users._() {
    firestore = FirebaseFirestore.instance;
  }

  static service_users get instance => _service_instance ??= service_users._();

  Future<model_user> getUserById(String id) async {
    DocumentSnapshot doc = await firestore.collection(model_user.KEY_COLLECTION_USERS).doc(id).get();
    if (!doc.exists) return null;
    return model_user.fromMap(doc.data());
  }

  Future<model_user> getUserByEmail(String email) async {
    QuerySnapshot query = await firestore
        .collection(model_user.KEY_COLLECTION_USERS)
        .where(model_user.KEY_EMAIL, isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (query.docs.length == 0 || !query.docs.first.exists) return null;
    return model_user.fromMap(query.docs.first.data());
  }

  Future<model_user> createNewUser(String name, String email, String profilePicUrl) async {
    model_user newUser = new model_user(name: name, email: email, profile_pic_url: profilePicUrl, join_date: DateTime.now());
    DocumentReference userDoc = firestore.collection(model_user.KEY_COLLECTION_USERS).doc();

    newUser.id = userDoc.id;
    await userDoc.set(newUser.toMap());
    return newUser;
  }
}