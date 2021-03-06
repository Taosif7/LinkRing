import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_ring/API/Models/model_group.dart';
import 'package:link_ring/API/Services/service_groups.dart';
import 'package:link_ring/Cubits/AppState/cubit_app.dart';
import 'package:link_ring/Screens/Commons/ErrorScreen.dart';
import 'package:link_ring/Screens/Commons/LoadingDataScreen.dart';
import 'package:link_ring/Screens/CreateGroupScreen.dart';
import 'package:link_ring/Screens/HomeScreen/Homepage.dart';
import 'package:link_ring/Screens/JoinGroupScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/LinkMessagesScreen.dart';
import 'package:link_ring/Screens/LinkMessagesScreen/SendLinkScreen.dart';
import 'package:link_ring/Screens/SignInScreen.dart';

Route<dynamic> routeGenerator(RouteSettings routeSettings, BuildContext context) {
  print(routeSettings.name);
  Uri path = Uri.parse(routeSettings.name);
  if (routeSettings.name == '/' || path.pathSegments.first == 'home') {
    return new CupertinoPageRoute(builder: (c) => Screen_HomePage());
  } else if (path.pathSegments.first == 'login' || path.pathSegments.first == 'logout' || path.pathSegments.first == 'signin') {
    return new CupertinoPageRoute(builder: (c) => Screen_SignIn());
  } else if (path.pathSegments.first == 'createGroup') {
    return new CupertinoPageRoute(builder: (c) => Screen_CreateGroup(), fullscreenDialog: true);
  } else if (path.pathSegments.first == 'joingroup') {
    if (!context.read<cubit_app>().auth.state.isLoggedIn) {
      return new CupertinoPageRoute(builder: (c) => Screen_SignIn());
    }
    if (path.queryParameters.containsKey('id')) {
      return new CupertinoPageRoute(builder: (c) => JoinGroupScreen(groupId: path.queryParameters['id']), fullscreenDialog: true);
    } else {
      return new CupertinoPageRoute(builder: (c) => ErrorScreen(errorMessage: "Group not found!", title: "Not found"));
    }
  } else if (path.pathSegments.first == 'group') {
    var groupId = path.pathSegments[1];
    if (path.pathSegments.length == 2) {
      // find group and show page
      return new CupertinoPageRoute(
          builder: (x) => new LoadingDataScreen((nav) async {
                model_group group = await service_groups.instance.getGroupById(groupId);

                if (group == null)
                  nav.pushReplacement(new PageRouteBuilder(
                    pageBuilder: (ctx, anim1, anim2) => new ErrorScreen(errorMessage: "Group not found!", title: "Not found"),
                    transitionDuration: Duration.zero,
                  ));
            else
              nav.pushReplacement(LinkMessagesScreen.getRoute(context, group));
          }));
    } else if (path.pathSegments.length == 3) {
      var operationPage = path.pathSegments[2];

      if (operationPage == 'new') {
        return new CupertinoPageRoute(
            builder: (x) => new LoadingDataScreen((nav) async {
                  model_group group = await service_groups.instance.getGroupById(groupId);

                  if (group == null)
                    nav.pushReplacement(new PageRouteBuilder(
                      pageBuilder: (ctx, anim1, anim2) => new ErrorScreen(errorMessage: "Group not found!", title: "Not found"),
                      transitionDuration: Duration.zero,
                    ));
                  else
                    nav.pushReplacement(SendLinkScreen.getRoute(context, group, path.queryParameters['link']));
                }));
      }

      // Settings or members
    } else {
      return new CupertinoPageRoute(builder: (c) => ErrorScreen(errorMessage: "Group not found!", title: "Not found"));
    }
  } else
    return new CupertinoPageRoute(builder: (c) => ErrorScreen(errorMessage: "You're lost", title: "Oops"));
}
