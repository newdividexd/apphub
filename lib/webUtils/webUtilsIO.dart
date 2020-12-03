import 'package:apphub/app.dart';
import 'package:apphub/webUtils/webUtils.dart';

class WebUtilsIO implements WebUtils {
  @override
  void download(String url, String name) {
    print('download');
    print(name);
    print(url);
  }

  @override
  void open(String url, String name) {
    print('open');
    print(name);
    print(url);
  }

  @override
  String getBrowser() {
    return null;
  }

  @override
  FlutterPlatform getSupportedPlatform() {
    return FlutterPlatform.Windows;
  }
}

WebUtils getUtils() => WebUtilsIO();
