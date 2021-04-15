import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/cubit_linkMessagesScreen.dart';
import 'package:link_ring/Cubits/LinkMessagesScreen/state_linkMessagesScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/widgets/LinkMessageItem.dart';

class LinkMessagesScreen extends StatelessWidget {
  cubit_linkMessagesScreen cubit;
  model_group group;

  LinkMessagesScreen(this.group) {
    cubit = new cubit_linkMessagesScreen(new state_linkMessagesScreen(this.group));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<cubit_linkMessagesScreen>.value(
        value: cubit,
        child: Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: Theme.of(context).primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(children: [
            BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (loadingCtx, state) {
              if (state.isLinksLoading)
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(child: CircularProgressIndicator(strokeWidth: 3), height: 20, width: 20),
                ));
              else
                return Container();
            }),
            Expanded(child: BlocBuilder<cubit_linkMessagesScreen, state_linkMessagesScreen>(builder: (linksViewCtx, state) {
              if (!state.isLinksLoading && state.links.length == 0) {
                return Center(child: Text("No Links"));
              } else
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (itemBuilderCtx, index) => LinkMessageItem(state.links[index]),
                  reverse: true,
                  itemCount: state.links.length,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                );
            })),
            Container(
              height: 60,
              color: Colors.red.shade100,
              child: Center(
                child: Text("Reserved for Toolbox for Sending Links"),
              ),
            ),
          ]),
        ));
  }
}
