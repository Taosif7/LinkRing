import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/API/Services/service_members.dart';
import 'package:link_ring/Utils/Constants.dart';

class service_links {
  static const API_ENDPOINT_SENDLINK = "https://linkring.herokuapp.com/ringlink";

  static service_links _service_instance;
  FirebaseFirestore firestore;

  service_links._() {
    firestore = FirebaseFirestore.instance;
  }

  static service_links get instance => _service_instance ??= service_links._();

  Future<model_link> getLinkById(String groupId, String id) async {
    DocumentSnapshot doc = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_link.KEY_COLLECTION_LINKS)
        .doc(id)
        .get();
    return model_link.fromMap(doc.data());
  }

  Future<List<model_link>> getLinkByLink(String groupId, String link) async {
    QuerySnapshot query = await firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_link.KEY_COLLECTION_LINKS)
        .where(model_link.KEY_LINK, isEqualTo: link)
        .get();
    List<model_link> links = [];
    query.docs.forEach((doc) => links.add(model_link.fromMap(doc.data())));
    return links;
  }

  Future<List<model_link>> getLinksForGroup(String groupId,
      {int quantity = 20, String lastItemId, List<model_member> senderMembers}) async {
    List<model_link> links = [];
    Query query = firestore
        .collection(model_group.KEY_COLLECTION_GROUPS)
        .doc(groupId)
        .collection(model_link.KEY_COLLECTION_LINKS)
        .limit(quantity)
        .orderBy(model_link.KEY_SENT_TIME, descending: true);

    if (lastItemId != null) {
      DocumentSnapshot lastDoc = await firestore
          .collection(model_group.KEY_COLLECTION_GROUPS)
          .doc(groupId)
          .collection(model_link.KEY_COLLECTION_LINKS)
          .doc(lastItemId)
          .get();
      query = query.startAfterDocument(lastDoc);
    }
    QuerySnapshot snapshot = await query.get();

    await Future.forEach(snapshot.docs, (element) async {
      model_link link = new model_link.fromMap(element.data());
      model_member sender = senderMembers.firstWhere((senderModel) => senderModel.id == link.sent_by, orElse: () => null);
      if (sender == null) {
        sender = await service_members.instance.getMemberById(groupId, link.sent_by);
        senderMembers.add(sender);
      }
      link.senderMember = sender;
      links.add(link);
    });
    return links;
  }

  Future<bool> sendLink(String groupId, String senderId, String link, String linkTitle) async {
    http.Response response = await http.post(
      Uri.parse(API_ENDPOINT_SENDLINK),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic " + SERVER_API_SECRET,
      },
      body: jsonEncode({
        "link_name": linkTitle.trim(),
        "link": link.trim(),
        "groupId": groupId,
        "senderId": senderId,
      }),
    );

    return response.statusCode == 200;
  }
}
