import 'package:apphub/app.dart';

import 'package:apphub/webUtils/webUtilsStub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:apphub/webUtils/webUtilsIO.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:apphub/webUtils/webUtilsHtml.dart';


abstract class WebUtils {
  void open(String url, String name);

  void download(String url, String name);

  String getBrowser();

  FlutterPlatform getSupportedPlatform();

  factory WebUtils() => getUtils();
}
