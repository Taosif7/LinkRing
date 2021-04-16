import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/API/Services/service_users.dart';

class service_groups {
  static service_groups _service_instance;
  FirebaseFirestore firestore;

  service_groups._() {
    firestore = FirebaseFirestore.instance;
  }

  static service_groups get instance => _service_instance ??= service_groups._();

  Future<model_group> getGroupById(String id) async {
    DocumentSnapshot doc = await firestore.collection(model_group.KEY_COLLECTION_GROUPS).doc(id).get();
    return model_group.fromMap(doc.data());
  }

  Future<List<model_group>> getGroupsByIds(List<String> groupIds) async {
    List<model_group> groups = [];

    // for every 10 elements, perform where in query to find groups
    for (int i = 0; i < groupIds.length; i += 10) {
      List<String> subList = groupIds.sublist(i, (i + 10 >= groupIds.length) ? groupIds.length : i + 10).toList();
      QuerySnapshot qs =
          await firestore.collection(model_group.KEY_COLLECTION_GROUPS).where(model_group.KEY_ID, whereIn: subList).get();
      qs.docs.forEach((doc) => groups.add(model_group.fromMap(doc.data())));
    }

    return groups;
  }

  Future<model_group> createGroup(model_group group, model_user creator) async {
    // Add creator user id to admins
    group.admin_users_ids.add(creator.id);

    // Create group in database
    DocumentReference newGroupDoc = firestore.collection(model_group.KEY_COLLECTION_GROUPS).doc();
    group.id = newGroupDoc.id;
    group.creation_time = DateTime.now();
    await newGroupDoc.set(group.toMap());

    // Add creator as member of group
    model_member member = model_member.fromUser(creator, true);
    await service_members.instance.addMember(group.id, member);

    // Add group Id to user
    await service_users.instance.addJoinedGroupId(creator.id, group.id);

    return group;
  }
}
