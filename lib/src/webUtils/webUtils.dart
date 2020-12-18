import 'package:apphub/src/app.dart';

import 'package:apphub/src/webUtils/webUtilsStub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:apphub/src/webUtils/webUtilsIO.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:apphub/src/webUtils/webUtilsHtml.dart';

abstract class WebUtils {
  Future<List<App>> getApps();

  void open(String url, String name);

  void download(String url, String name);

  String getBrowser();

  Env getSupportedPlatform();

  factory WebUtils() => getUtils();
}
