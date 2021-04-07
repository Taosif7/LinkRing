import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Cubits/AppState/state_app.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/LinkMessagesScreen.dart';
import 'package:link_ring/Screens/SignInScreen.dart';

class Screen_HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Link Ring"),
        actions: [
          BlocBuilder<cubit_app, state_app>(
            builder: (ctx, state) {
              return IconButton(
                  icon: CircleAvatar(
                    backgroundImage:
                        (state.isLoading) ? null : NetworkImage(context.read<cubit_app>().state.currentUser.profile_pic_url),
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: (state.isLoading) ? 5 : 20,
                  ),
                  onPressed: () {
                    // TODO : Open options menu
                    Navigator.of(context).pushReplacement(new CupertinoPageRoute(builder: (_) => Screen_SignIn()));
                    context.read<cubit_app>().auth.signOut(context);
                  });
            },
          ),
        ],
      ),
      body: BlocBuilder<cubit_app, state_app>(
        builder: (ctx, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else
            return ListView.builder(
                itemBuilder: (ctx, idx) {
                  model_group group = context.read<cubit_app>().state.groups[idx];
                  return ListTile(
                    title: Text(group.name, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400)),
                    leading: CircleAvatar(backgroundImage: NetworkImage(group.icon_url), backgroundColor: Colors.blueGrey),
                    trailing: Icon(CupertinoIcons.forward, color: Theme.of(context).primaryColor),
                    onTap: () {
                      Navigator.push(context, new CupertinoPageRoute(builder: (x) => new LinkMessagesScreen(group)));
                    },
                  );
                },
                shrinkWrap: true,
                itemCount: context.read<cubit_app>().state.groups.length);
        },
      ),
    );
  }
}
