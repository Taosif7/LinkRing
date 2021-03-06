import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Services/service_users.dart';

class service_members {
  static service_members _service_instance;
  FirebaseFirestore firestore;

  service_members._() {
    firestore = FirebaseFirestore.instance;
  }

  static service_members get instance => _service_instance ??= service_members._();

  Future<List<model_member>> getMembers(String groupId, {int quantity = 20, String afterThisId, bool joined = true}) async {
    Query query = firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .limit(quantity)
        .where(model_member.KEY_IS_JOINED, isEqualTo: joined)
        .orderBy(model_member.KEY_NAME);

    if (afterThisId != null) {
      DocumentSnapshot prevDoc;
      prevDoc = await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .doc(groupId)
          .collection(model_member.KEY_COLLECTION_MEMBERS)
          .doc(afterThisId)
          .get();
      query = query.startAfterDocument(prevDoc);
    }
    QuerySnapshot snapshot = await query.get();

    List<model_member> members = [];
    snapshot.docs.forEach((doc) => members.add(new model_member.fromJson(doc.data())));

    return members;
  }

  Future<model_member> getMemberById(String groupId, String memberId) async {
    // Find member doc
    DocumentSnapshot memberDoc = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(memberId)
        .get();

    if (!memberDoc.exists) return null;
    return new model_member.fromJson(memberDoc.data());
  }

  Future<List<model_member>> getMembersByIds(String groupId, List<String> memberIds) async {
    List<model_member> members = [];

    // for every 10 elements, perform where in query to find members
    for (int i = 0; i < memberIds.length; i += 10) {
      List<String> subList = memberIds.sublist(i, (i + 10 >= memberIds.length) ? memberIds.length : i + 10).toList();
      QuerySnapshot qs = await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .doc(groupId)
          .collection(model_member.KEY_COLLECTION_MEMBERS)
          .where(model_group.KEY_ID, whereIn: subList)
          .get();
      qs.docs.forEach((doc) => members.add(model_member.fromJson(doc.data())));
    }

    return members;
  }

  /// Method to update member properties
  Future<void> updateMemberInfo(String groupId, model_member member) async {
    Map<String, dynamic> updateData = member.toJson();
    updateData.remove(model_member.KEY_JOINED_TIME); // Don't update joined time
    await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(member.id)
        .update(updateData);
  }

  /// Method to update tokens of given user in given groups
  Future<void> updateMemberTokens(List<String> groupIds, String userId, String token) async {
    await Future.forEach(groupIds, (gid) async {
      await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .doc(gid)
          .collection(model_member.KEY_COLLECTION_MEMBERS)
          .doc(userId)
          .update({model_member.KEY_PUSH_TOKEN: token});
    });
  }

  Future<void> addMember(String groupId, model_member member) async {
    // Find member doc
    DocumentSnapshot memberDoc = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(member.id)
        .get();

    // return if it already exists
    if (memberDoc.exists) return;
    member.joinedOn = DateTime.now();
    await memberDoc.reference.set(member.toJson());
  }

  Future<void> removeMember(String groupId, String memberId) async {
    // delete member doc
    await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(memberId)
        .delete();

    // Update group in user property
    await service_users.instance.removeJoinedGroupId(memberId, groupId);
    await service_users.instance.removeWaitingGroupId(memberId, groupId);
  }

  Future<void> admitMember(String groupId, String memberId) async {
    // Update member doc
    await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(memberId)
        .update({
      model_member.KEY_IS_JOINED: true,
      model_member.KEY_JOINED_TIME: DateTime.now().toUtc().toString(),
    });

    // Update group in user property
    await service_users.instance.removeWaitingGroupId(memberId, groupId);
    await service_users.instance.addJoinedGroupId(memberId, groupId);
  }

  Future<void> unAdmitMember(String groupId, String memberId) async {
    // Update member doc
    await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .doc(memberId)
        .update({
      model_member.KEY_IS_JOINED: false,
    });

    // Update group in user property
    await service_users.instance.removeJoinedGroupId(memberId, groupId);
    await service_users.instance.addWaitingGroupId(memberId, groupId);
  }

  Future<List<model_member>> searchMemberByName(String groupId, String name) async {
    List<model_member> members = [];

    QuerySnapshot qs = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_member.KEY_COLLECTION_MEMBERS)
        .orderBy(model_member.KEY_NAME)
        .startAt([name]).endAt([name + "\uf8ff"]).get();

    qs.docs.forEach((element) => members.add(new model_member.fromJson(element.data())));

    return members;
  }
}
