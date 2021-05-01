import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Models/model_link.dart';
import 'package:link_ring/API/Models/model_user.dart';
import 'package:link_ring/API/Services/service_links.dart';
import 'package:link_ring/API/Services/service_users.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/cubit_linkMessagesScreen.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';
import 'package:link_ring/Screens/Commons/CupertinoBackButton.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/GroupInfoScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/SendLinkScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/widgets/LinkMessageItem.dart';
import 'package:link_ring/Screens/MemberListScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'file:///D:/AndroidProjects/link_ring/lib/Screens/Commons/RoundIconLabelButton.dart';

class LinkMessagesScreen extends StatefulWidget {
  model_group group;

  LinkMessagesScreen(this.group);

  @override
  _LinkMessagesScreenState createState() => _LinkMessagesScreenState();

  static CupertinoPageRoute getRoute(BuildContext context, model_group group, {bool disableTransition = false}) {
    return new CupertinoPageRoute(
        builder: (x) => BlocProvider(
            create: (c) => cubit_linkMessagesScreen(state_linkMessagesScreen(group), context.read<cubit_app>().state.currentUser),
            child: LinkMessagesScreen(group)),
        settings: RouteSettings(name: 'group/${group.id}'));
  }
}

class _LinkMessagesScreenState extends State<LinkMessagesScreen> with SingleTickerProviderStateMixin {
  bool showToolbox = false;
  ScrollController _scrollController = new ScrollController();
  model_link selectedLink;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          // You're at the bottom.
          // Load more link messages
          context.read<cubit_linkMessagesScreen>().loadMoreLinks();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5,
        title: InkWell(
          onTap: () => Navigator.push(context, GroupInfoScreen.getRoute(context, widget.group)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            child: Row(
              children: [
                Hero(tag: 'GroupPicture' + widget.group.id, child: ProfileCircleAvatar.fromGroup(widget.group, size: 18)),
                SizedBox(width: 10),
                Text(widget.group.name),
              ],
            ),
          ),
        ),
        leading: CupertinoBackIconButton(),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                if (context.read<cubit_linkMessagesScreen>().state.isSilent)
                  PopupMenuItem(
                      child: ListTile(
                          title: Text("Unmute"), leading: Icon(Icons.volume_up), contentPadding: EdgeInsets.zero, dense: true),
                      value: 1)
                else
                  PopupMenuItem(
                      child: ListTile(
                          title: Text("Mute"), leading: Icon(Icons.volume_off), contentPadding: EdgeInsets.zero, dense: true),
                      value: 2)
              ];
            },
            onSelected: (idx) async {
              if (idx == 1) {
                setGroupSilence(context, false);
              } else if (idx == 2) {
                setGroupSilence(context, true);
              }
            },
          )
        ],
      ),
      body: Column(children: [
        BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (loadingCtx, state) {
          if (state.isLinksLoading)
            return Container(
              color: Theme.of(context).primaryColor.withAlpha(10),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(child: CircularProgressIndicator(strokeWidth: 3), height: 20, width: 20),
              )),
            );
          else
            return Container();
        }),
        Expanded(child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (linksViewCtx, state) {
          return Stack(alignment: Alignment.bottomCenter, children: [
            if (!state.isLinksLoading && state.links.length == 0)
              Center(child: Text("No Links"))
            else
              ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                itemBuilder: (itemBuilderCtx, index) {
                  bool showLeading =
                      (index == state.links.length - 1) || state.links[index].sent_by != (state.links[index + 1]?.sent_by ?? "");
                  return LinkMessageItem(
                    state.links[index],
                    showLeading: showLeading,
                    selected: selectedLink == state.links[index],
                    onMessageTap: (link) {
                      setState(() {
                        if (selectedLink == link && showToolbox)
                          closeToolbox();
                        else
                          openToolbox(link);
                      });
                    },
                  );
                },
                reverse: true,
                itemCount: state.links.length,
                padding: EdgeInsets.fromLTRB(10, 5, 10, 120),
              ),
            Container(
              height: 95,
              margin: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: AnimatedCrossFade(
                      duration: Duration(milliseconds: 300),
                      secondChild: !context.read<cubit_linkMessagesScreen>().state.isAdmin
                          ? Center(child: Text("Tap a link for options"))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RoundIconLabelButton(Icon(Icons.add_link), "New Link", onTap: () async {
                                  Navigator.push(
                                      context,
                                      SendLinkScreen.getRoute(
                                          context, widget.group, (await Clipboard.getData("text/plain")).text));
                                }),
                              ],
                            ),
                      firstChild: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RoundIconLabelButton(Icon(Icons.link), "Open", onTap: () async {
                            if (await canLaunch(selectedLink.link)) launch(selectedLink.link);
                            closeToolbox();
                          }),
                          SizedBox(width: 10),
                          RoundIconLabelButton(Icon(Icons.copy), "Copy", onTap: () {
                            Clipboard.setData(new ClipboardData(text: selectedLink.link));
                            closeToolbox();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(content: Text("Link Copied!"), behavior: SnackBarBehavior.floating));
                          }),
                          SizedBox(width: 10),
                          if (context.read<cubit_linkMessagesScreen>().state.isAdmin) ...[
                            RoundIconLabelButton(
                              Icon(Icons.call_made_outlined),
                              "Rings",
                              onTap: () => showAcknowledgementScreen(context, selectedLink.id),
                            ),
                            SizedBox(width: 10),
                          ],
                          RoundIconLabelButton(
                            Icon(Icons.close, color: Colors.white),
                            "Close",
                            buttonColor: Colors.redAccent,
                            onTap: () {
                              closeToolbox();
                            },
                          ),
                        ],
                      ),
                      crossFadeState: showToolbox ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    ),
                  ),
                ),
              ),
            ),
          ]);
        })),
      ]),
    );
  }

  void openToolbox(model_link link) {
    setState(() {
      this.selectedLink = link;
      this.showToolbox = true;
    });
  }

  void closeToolbox() {
    setState(() {
      this.selectedLink = null;
      this.showToolbox = false;
    });
  }

  Future<void> setGroupSilence(BuildContext context, bool silent) async {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Group is now muted")));
    model_user user = await service_users.instance.changeGroupSilence(
        context.read<cubit_linkMessagesScreen>().currentUser.id, context.read<cubit_linkMessagesScreen>().state.group.id, silent);
    context.read<cubit_linkMessagesScreen>().emit(context.read<cubit_linkMessagesScreen>().state.copy(isSilent: silent));
    context.read<cubit_app>().updateUser(user);
  }

  void showAcknowledgementScreen(BuildContext context, String linkId) {
    Navigator.of(context).push(new CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => new MemberListScreen(
              "Acknowledgement List",
              [],
              hideActionsForMembers: [context.read<cubit_linkMessagesScreen>().currentUser.id],
              onLoadMore: (m) => service_links.instance
                  .getAcknowledgementMembers(context.read<cubit_linkMessagesScreen>().state.group.id, linkId, afterThisId: m?.id),
              buttons: [],
            )));
  }
}
