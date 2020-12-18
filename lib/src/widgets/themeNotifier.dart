import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final SharedPreferences prefs;

  bool _dark;

  ThemeNotifier(this.prefs) {
    this.dark = this.prefs.getBool('dark');
    if (this.dark == null) {
      this._dark = true;
    }
  }

  bool get dark => this._dark;

  set dark(bool value) {
    this._dark = value;
    this.prefs.setBool('dark', value);
    this.notifyListeners();
  }

  ThemeData get theme => this._dark ? ThemeData.dark() : ThemeData.light();
}

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Text('Options')),
        Row(
          children: [
            SizedBox(width: 10),
            Text('Night mode'),
            SizedBox(width: 10),
            Icon(Icons.wb_sunny),
            Switch(
              onChanged: (value) {
                Provider.of<ThemeNotifier>(context, listen: false).dark = value;
              },
              value: Provider.of<ThemeNotifier>(context, listen: false).dark,
            ),
            Icon(Icons.nights_stay),
          ],
        )
      ],
    ),
  );
}
