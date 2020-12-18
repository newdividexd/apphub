import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:apphub/src/app.dart';

import 'package:apphub/src/webUtils/webUtils.dart';

import 'package:apphub/src/widgets/appWidget.dart';
import 'package:apphub/src/widgets/themeNotifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait<dynamic>([
    WebUtils().getApps(),
    SharedPreferences.getInstance(),
  ]).then((value) => runApp(
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) => ThemeNotifier(value[1]),
          child: AppHub(value[0]),
        ),
      ));
}

class AppHub extends StatelessWidget {
  final List<App> apps;

  AppHub(this.apps);

  @override
  Widget build(BuildContext context) => Consumer<ThemeNotifier>(
        builder: (context, notifier, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App Hub',
          theme: notifier.theme,
          home: Scaffold(
            appBar: AppBar(title: Text('App Hub')),
            drawer: buildDrawer(context),
            body: ListView(
              children: this.apps.map((app) => AppWidget(app, WebUtils())).toList(),
            ),
          ),
        ),
      );
}
