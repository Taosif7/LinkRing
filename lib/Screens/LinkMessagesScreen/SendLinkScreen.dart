import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Services/service_links.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/Buttons.dart';
import 'package:link_ring/Utils/RegexPatterns.dart';

class SendLinkScreen extends StatefulWidget {
  String link;
  model_group group;
  TextEditingController _linkEditingController = new TextEditingController();

  SendLinkScreen(this.link, this.group) {
    if (RegexPatterns.links.hasMatch(this.link)) _linkEditingController = new TextEditingController(text: this.link);
  }

  @override
  _SendLinkScreenState createState() => _SendLinkScreenState();

  static CupertinoPageRoute getRoute(BuildContext context, model_group group, String link) {
    return new CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (x) => SendLinkScreen(link, group),
        settings: RouteSettings(name: 'group/${group.id}/new?link=$link'));
  }
}

class _SendLinkScreenState extends State<SendLinkScreen> {
  TextEditingController _titleEditingController = new TextEditingController();
  bool linkSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ring new link")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: widget._linkEditingController,
              decoration: InputDecoration(
                  hintText: "Paste link here",
                  icon: Icon(Icons.link, color: Colors.black),
                  contentPadding: const EdgeInsets.all(10)),
              maxLines: 10,
              minLines: 1,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _titleEditingController,
              decoration: InputDecoration(
                  hintText: "Optional Title",
                  icon: Icon(Icons.title, color: Colors.black),
                  contentPadding: const EdgeInsets.all(10)),
              maxLines: 10,
              minLines: 1,
            ),
            SizedBox(height: 20),
            linkSending
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ColorButton(
                        label: "Ring Link",
                        onPressed: () async {
                          if (linkSending) return;

                          // check Link validity
                          if (!RegexPatterns.links.hasMatch(widget._linkEditingController.text)) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(content: Text("Incorrect Link"), behavior: SnackBarBehavior.floating));
                            return;
                          }

                          // Ask for confirmation
                          bool confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogCtx) {
                                return new AlertDialog(
                                  title: Text("Do you really want to ring?"),
                                  actions: [
                                    TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true)),
                                    TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false)),
                                  ],
                                );
                              });
                          if (!confirm) return;

                          // Set state as sending
                          setState(() => linkSending = true);

                          bool result = await service_links.instance.sendLink(
                              widget.group.id,
                              context.read<cubit_app>().state.currentUser.id,
                              widget._linkEditingController.text,
                              _titleEditingController.text);

                          ScaffoldMessenger.maybeOf(context).showSnackBar(new SnackBar(
                              content: Text(result ? "Ring Success" : "Some error occurred"),
                              behavior: SnackBarBehavior.floating));

                          Navigator.of(context).pop();
                        },
                        color: Colors.green))
          ],
        ),
      ),
    );
  }
}
