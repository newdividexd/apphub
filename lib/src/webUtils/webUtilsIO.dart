import 'dart:io';

import 'package:apphub/src/app.dart';
import 'package:apphub/src/webUtils/webUtils.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path;

import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

abstract class WebUtilsIO implements WebUtils {
  final Env platform;

  WebUtilsIO(this.platform);

  @override
  Future<String> getAppsDef() async {
    final url = await rootBundle.loadString('assets/repositories_url.txt');
    final response = await http.get(url);
    return response.body;
  }

  @override
  void open(String url, String name) {
    launcher.launch(url);
  }

  @override
  String getBrowser() {
    return null;
  }

  @override
  Env getSupportedPlatform() {
    return this.platform;
  }
}

class WebUtilsMobile extends WebUtilsIO {
  WebUtilsMobile(Env platform) : super(platform);

  @override
  Future<String> getAppsDef() async {
    await FlutterDownloader.initialize(debug: true);
    return super.getAppsDef();
  }

  @override
  void download(String url, String name) async {
    if (await Permission.storage.request().isGranted) {
      final dir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: dir,
      );
    }
  }
}

class WebUtilsDesktop extends WebUtilsIO {
  WebUtilsDesktop(Env platform) : super(platform);

  @override
  void download(String url, String name) async {
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;
    final dir = await path.getDownloadsDirectory();

    final client = http.Client();
    final request = new http.Request('GET', uri);

    final response = await client.send(request);

    final output = File('${dir.path}/$fileName').openWrite();

    output.addStream(response.stream).then((value) => output.close());
  }
}

WebUtils getUtils() {
  if (Platform.isAndroid) {
    return WebUtilsMobile(Env.Android);
  } else if (Platform.isIOS) {
    return WebUtilsMobile(Env.IOS);
  } else {
    return WebUtilsDesktop(Env.Windows);
  }
}
