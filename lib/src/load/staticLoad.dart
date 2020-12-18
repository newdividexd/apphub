import 'dart:convert';

import 'package:apphub/src/app.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:version/version.dart';

EnvVersion _parseEnvVersion(Env platform, List<dynamic> filesDef) {
  List<EnvFile> files = filesDef
      .map<EnvFile>((fileDef) => EnvFile(
            fileDef['name'],
            fileDef['mbytes'],
            fileDef['url'],
          ))
      .toList();
  return EnvVersion(
    platform,
    files.firstWhere((file) => !file.name.contains('-')),
    files,
  );
}

AppVersion _parseVersion(Map<String, dynamic> versionDef) {
  Version version = Version.parse(versionDef['version']);
  DateTime publishDate = DateTime.parse(versionDef['publish_date']);
  Map<Env, EnvVersion> platforms = versionDef['platforms'].map<Env, EnvVersion>(
    (envName, files) {
      Env platform = Env.values.firstWhere((env) => env.name.toLowerCase() == envName);
      return MapEntry(platform, _parseEnvVersion(platform, files));
    },
  );
  return AppVersion(version, publishDate, platforms);
}

App _parseApp(Map<String, dynamic> appDef) {
  String name = appDef['name'];
  String url = appDef['url'];
  List<AppVersion> versions = appDef['versions'].map<AppVersion>((versionDef) => _parseVersion(versionDef)).toList();
  versions.sort((v1, v2) => v2.version.compareTo(v1.version));
  return App(name, url, versions.first, versions);
}

Future<List<App>> staticApps() async {
  final data = await rootBundle.loadString('assets/static_apps.json');
  return json.decode(data).map<App>((appDef) => _parseApp(appDef)).toList();
}
