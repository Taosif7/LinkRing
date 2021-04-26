import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Utils/DateFormatConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkMessageItem extends StatelessWidget {
  model_link link;
  bool showLeading;
  bool selected;

  Function onLinkTap;

  LinkMessageItem(this.link, {this.showLeading = true, this.selected = false, onMessageTap(model_link link)}) {
    this.onLinkTap = onMessageTap;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Opacity(
            opacity: this.showLeading ? 1 : 0,
            child: Row(children: [
              ProfileCircleAvatar.fromUser(context.read<cubit_app>().state.currentUser, size: 15),
              SizedBox(width: 5),
              Icon(Icons.link, size: 15),
            ]),
          ),
          SizedBox(width: 5),
          Expanded(
              child: GestureDetector(
            onDoubleTap: () async {
              // Open link directly
              if (await canLaunch(link.link)) await launch(link.link);
            },
            onTap: () => onLinkTap(link),
            onLongPress: () {
              onLinkTap(link);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: selected ? Colors.blue.withAlpha(30) : Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (link.hasName) Text(link.name, style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.start),
                  if (link.hasName) SizedBox(height: 2),
                  Text(link.link, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.blue)),
                  SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      TimeFormat.format(link.sent_time),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
