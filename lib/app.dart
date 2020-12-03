import 'dart:collection';

enum FlutterPlatform {
  Web,
  Windows,
  Android,
  Linux,
  MacOS,
  IOS,
}

extension FlutterPlatformExtension on FlutterPlatform {
  String get name => this.toString().substring("FlutterPlatform.".length);
}

class Location {
  final String url;

  Location(this.url);
}

class PlatformFile {
  final String name;
  final String target;
  final String size;
  final String url;

  PlatformFile(this.name, this.target, this.size, this.url);
}

class PlatformDownload extends Location implements PlatformFile {
  final String name;
  final String target;
  final String size;
  final UnmodifiableListView<PlatformFile> subFiles;

  PlatformDownload(this.name, this.target, this.size, String url, this.subFiles) : super(url);
}

class App {
  final String name;
  final Map<FlutterPlatform, Location> platforms;

  bool hasPlatform(FlutterPlatform platform) {
    return this.platforms.containsKey(platform);
  }

  App(this.name, this.platforms);
}
