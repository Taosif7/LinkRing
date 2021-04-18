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

  Future<model_user> addJoinedGroupId(String userId, String groupId) async {
    // Get user groups
    DocumentSnapshot userDoc = await firestore.collection(model_user.KEY_COLLECTION_USERS).doc(userId).get();
    model_user user = model_user.fromMap(userDoc.data());
    List<String> joinedGroups = user.joinedGroupsIds;

    // Add joined group Id and filter list for distinct items
    joinedGroups.add(groupId);
    user.joinedGroupsIds = joinedGroups.toSet().toList();

    // Update in database
    await userDoc.reference.update({model_user.KEY_GROUPS: user.joinedGroupsIds});

    return user;
  }

  Future<model_user> addWaitingGroupId(String userId, String groupId) async {
    // Get user groups
    DocumentSnapshot userDoc = await firestore.collection(model_user.KEY_COLLECTION_USERS).doc(userId).get();
    model_user user = model_user.fromMap(userDoc.data());
    List<String> waitingGroups = user.waitingGroupsIds;

    // Add waiting group Id and filter list for distinct items
    waitingGroups.add(groupId);
    user.waitingGroupsIds = waitingGroups.toSet().toList();

    // Update in database
    await userDoc.reference.update({model_user.KEY_WAITING_GROUPS: user.waitingGroupsIds});

    return user;
  }

  Future<void> updateUserToken(String userId, String token) async {
    await firestore.collection(model_user.KEY_COLLECTION_USERS).doc(userId).update({model_user.KEY_MSG_TOKEN: token});
  }
}
