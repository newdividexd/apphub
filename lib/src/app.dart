import 'package:version/version.dart';

enum Env {
  Web,
  Windows,
  Android,
  Linux,
  MacOS,
  IOS,
}

extension EnvExtension on Env {
  String get name => this.toString().substring("Env.".length);
}

class EnvFile {
  final String name;
  final double mbytes;
  final String url;

  EnvFile(this.name, this.mbytes, this.url);
}

class EnvVersion {
  final Env platform;
  final EnvFile main;
  final List<EnvFile> files;

  EnvVersion(this.platform, this.main, this.files);
}

class AppVersion {
  final Version version;
  final DateTime publishDate;
  final Map<Env, EnvVersion> platforms;

  AppVersion(this.version, this.publishDate, this.platforms);
}

class App {
  final String name;
  final String webUrl;
  final AppVersion main;
  final List<AppVersion> version;

  App(this.name, this.webUrl, this.main, this.version);
}
