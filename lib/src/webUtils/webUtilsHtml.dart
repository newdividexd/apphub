// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/services.dart' show rootBundle;
import 'package:platform_detect/platform_detect.dart' as web;

import 'package:apphub/src/app.dart';
import 'package:apphub/src/webUtils/webUtils.dart';

class WebUtilsHtml implements WebUtils {
  @override
  Future<String> getAppsDef() async {
    return rootBundle.loadString('assets/git_repositories.json');
  }

  @override
  void open(String url, String name) {
    html.window.open(url, name);
  }

  @override
  void download(String url, String name) {
    html.window.open(url, name);
  }

  @override
  String getBrowser() {
    if (web.browser.isChrome) {
      return 'chrome';
    } else if (web.browser.isFirefox) {
      return 'mozilla';
    } else if (web.browser.isSafari) {
      return 'safari';
    } else if (web.browser.isInternetExplorer) {
      return 'explorer';
    } else if (web.browser.isWKWebView) {
      return 'apple';
    } else if (web.Browser.navigator.userAgent.toLowerCase().contains('OPR')) {
      return 'opera';
    } else {
      return null;
    }
  }

  @override
  Env getSupportedPlatform() {
    String system = web.operatingSystem.name.toLowerCase();
    if (system.contains('windows')) {
      return Env.Windows;
    }
    String userAgent = web.OperatingSystem.navigator.userAgent;
    if (userAgent != null && userAgent.toLowerCase().contains('android')) {
      return Env.Android;
    }
    return null;
  }
}

WebUtils getUtils() => WebUtilsHtml();
