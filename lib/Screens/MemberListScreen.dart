import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_ring/API/Models/model_member.dart';
import 'package:link_ring/Screens/Commons/ProfileCircleAvatar.dart';

class MemberListScreen extends StatefulWidget {
  // Properties
  String title;
  List<model_member> members = [];
  List<String> hideActionsForMembers = [];
  Future<List<model_member>> Function(model_member lastItem) onLoadMore;
  Future<List<model_member>> Function(String query) onSearch;
  void Function(model_member member) onMemberTap;
  List<Map<String, bool Function(model_member member)>> buttons = [];

  MemberListScreen(this.title, List<model_member> initialList,
      {this.onLoadMore, this.onSearch, this.buttons = const [], this.hideActionsForMembers = const []}) {
    members.addAll(initialList);
  }

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  ScrollController _scrollController = new ScrollController();
  bool membersLoading = false;
  bool moreMembersAvailable = true;
  List<model_member> activeList;
  List<model_member> searchResults = [];
  TextEditingController searchTextController = new TextEditingController();

  @override
  void initState() {
    activeList = widget.members;

    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
        setState(() => membersLoading = true);
        List<model_member> moreMembers = await widget.onLoadMore(widget.members.last);
        if (moreMembers != null && moreMembers.length > 0) widget.members.addAll(moreMembers);
        setState(() {
          membersLoading = false;
          moreMembersAvailable = moreMembers.length != 0;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleSpacing: 0,
        bottom: widget.onSearch != null
            ? PreferredSize(
                preferredSize: Size(double.infinity, kToolbarHeight),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: TextField(
                    controller: searchTextController,
                    onChanged: (q) async {
                      if (q.length == 0) {
                        setState(() {
                          activeList = widget.members;
                          membersLoading = false;
                        });
                      } else {
                        setState(() {
                          searchResults.clear();
                          membersLoading = true;
                          activeList = searchResults;
                        });
                        List<model_member> results = await widget.onSearch(q);
                        setState(() {
                          searchResults = results;
                          activeList = searchResults;
                          membersLoading = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        fillColor: Colors.blueGrey.shade50,
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: "Search",
                        isDense: true,
                        suffixIcon: searchTextController.text.length > 0
                            ? IconButton(
                                icon: Icon(Icons.cancel, color: Colors.blueGrey),
                                onPressed: () => setState(() {
                                  searchTextController.clear();
                                  setState(() {
                                    activeList = widget.members;
                                    membersLoading = false;
                                  });
                                }),
                              )
                            : null),
                    textInputAction: TextInputAction.search,
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (membersLoading)
            Container(
              color: Theme.of(context).primaryColor.withAlpha(10),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(child: CircularProgressIndicator(strokeWidth: 3), height: 20, width: 20),
              )),
            ),
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                itemCount: activeList.length,
                padding: EdgeInsets.symmetric(vertical: 5),
                itemBuilder: (itemCtx, idx) {
                  model_member member = activeList[idx];
                  return ListTile(
                      leading: ProfileCircleAvatar.fromMember(member),
                      horizontalTitleGap: 10,
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                      title: Text(member.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(member.email),
                      onTap: widget.onMemberTap != null ? () => widget.onMemberTap(member) : null,
                      trailing: widget.buttons.length > 0 && !widget.hideActionsForMembers.contains(member.id)
                          ? PopupMenuButton(
                              tooltip: "Options",
                              itemBuilder: (ctx) {
                                return List.generate(
                                    widget.buttons.length,
                                    (index) => PopupMenuItem(
                                          child: Text(widget.buttons[index].keys.first),
                                          value: index,
                                        ));
                              },
                              onSelected: (val) {
                                bool removed = widget.buttons[val].values.first(member);
                                if (removed) {
                                  widget.members.remove(member);
                                  setState(() {});
                                }
                              },
                            )
                          : null);
                }),
          ),
        ],
      ),
    );
  }
}
