import 'dart:collection';
import 'dart:convert';

import 'package:apphub/app.dart';
import 'package:flutter/services.dart' show rootBundle;

void _resolveKey(String reference, int brk, Map<String, dynamic> data) {
  int brkend = reference.lastIndexOf(']');
  String key = reference.substring(brk + 1, brkend);
  String subReference = reference.substring(0, brk);
  dynamic subData = _resolve(subReference, data);
  if (subData is List) {
    data[reference] = subData[int.parse(key)];
  } else if (subData is Map) {
    data[reference] = subData[key];
  }
}

dynamic _resolve(String reference, Map<String, dynamic> data) {
  if (!data.containsKey(reference)) {
    int brk = reference.lastIndexOf('[');
    if (brk != -1) {
      _resolveKey(reference, brk, data);
    } else {
      throw ArgumentError('$reference not in ${data.keys.toList()}');
    }
  }
  return data[reference];
}

String _parseReplace(String format, Map<String, dynamic> data) {
  String result = format;
  String reference;
  dynamic value;
  while (result.indexOf('\${') != -1) {
    int start = result.indexOf('\${');
    int end = result.indexOf('}');
    reference = result.substring(start + 2, end);
    value = _resolve(reference, Map.from(data));
    if (value is List) {
      value = value[0];
    }
    result = result.substring(0, start) + value + result.substring(end + 1);
  }
  return result;
}

PlatformFile _buildFile(String ext, Map<String, dynamic> def, Map<String, dynamic> data) {
  String target = def['target'];
  return PlatformFile(
    '${data['name']}$target',
    target,
    def['size'],
    _parseReplace('${data['release']}$target.$ext', data),
  );
}

PlatformDownload _buildWindows(Map<String, dynamic> appDef, Map<String, dynamic> appData) {
  Map<String, dynamic> fileDef = appDef['windows'][0];
  PlatformFile file = _buildFile('zip', fileDef, appData);
  return PlatformDownload(
    file.name,
    file.target,
    file.size,
    file.url,
    UnmodifiableListView([]),
  );
}

PlatformDownload _buildAndroid(Map<String, dynamic> appDef, Map<String, dynamic> appData) {
  List<PlatformFile> files = List<PlatformFile>.from(
    appDef['android'].map((target) => _buildFile('apk', target, appData)),
  );
  PlatformFile root = files.removeAt(0);
  return PlatformDownload(
    root.name,
    root.target,
    root.size,
    root.url,
    UnmodifiableListView(files),
  );
}

Future<List<App>> loadEntries() async {
  final data = await rootBundle.loadString('assets/apps.json');
  Map<String, dynamic> appContextDef = json.decode(data);
  Map<String, dynamic> baseData = {
    'url': appContextDef['url'],
    'files': appContextDef['files'],
  };
  List<dynamic> appsDef = appContextDef['apps'];
  return List<App>.from(appsDef.map((appDef) {
    var name = appDef['name'];
    Map<FlutterPlatform, Location> platforms = Map();
    Map<String, dynamic> appData = Map.from(baseData);
    appData['name'] = name;
    appData['release'] = appDef['release'];
    if (appDef.containsKey('web')) {
      platforms[FlutterPlatform.Web] = Location(
        _parseReplace(appDef['web'], appData),
      );
    }
    if (appDef.containsKey('windows')) {
      platforms[FlutterPlatform.Windows] = _buildWindows(appDef, appData);
    }
    if (appDef.containsKey('android')) {
      platforms[FlutterPlatform.Android] = _buildAndroid(appDef, appData);
    }
    return App(name, platforms);
  }));
}
