import 'package:apphub/app.dart';
import 'package:apphub/webUtils/webUtils.dart';
import 'package:flutter/material.dart';

import 'package:apphub/utils.dart';

class AppWidget extends StatelessWidget {
  final App app;
  final WebUtils utils;
  final bool expanded;

  AppWidget(this.app, this.utils, this.expanded);

  Widget _buildWebIcon(double size) {
    String browser = this.utils.getBrowser();
    if (browser != null) {
      return SizedBox(
        height: size,
        width: size,
        child: Image.asset('assets/browsers/$browser.png'),
      );
    } else {
      return Icon(Icons.open_in_browser, size: size);
    }
  }

  void _openWeb() {
    return this.utils.open(this.app.platforms[FlutterPlatform.Web].url, this.app.name);
  }

  void _download(PlatformFile file) {
    return this.utils.download(file.url, file.name);
  }

  Widget buildDownload(FlutterPlatform platform, {PlatformFile file}) {
    PlatformFile target = file;
    if (target == null) {
      target = this.app.platforms[platform] as PlatformFile;
    }
    return Padding(
      padding: EdgeInsets.all(5),
      child: RaisedButton(
        onPressed: () => this._download(target),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(children: [
            SizedBox(height: 25, width: 25, child: Image.asset('assets/browsers/${platform.name.toLowerCase()}.png')),
            SizedBox(width: 10),
            if (file != null) Text('${platform.name.toLowerCase()}${file.target}'),
            if (file != null) SizedBox(width: 10),
            Icon(Icons.file_download, size: 25),
          ]),
        ),
      ),
    );
  }

  Widget buildPlatforms(BuildContext context) {
    FlutterPlatform sysPlat = this.utils.getSupportedPlatform();
    return Row(
      children: [
        if (this.app.hasPlatform(FlutterPlatform.Web))
          Padding(
            padding: EdgeInsets.all(5),
            child: RaisedButton(
              onPressed: () => this._openWeb(),
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      _buildWebIcon(25),
                      SizedBox(width: 10),
                      Text('Open Web'),
                    ],
                  )),
            ),
          ),
        if (this.app.hasPlatform(sysPlat)) this.buildDownload(sysPlat),
      ],
    );
  }

  List<Widget> buildAllDownloads() {
    return [
      if (this.app.hasPlatform(FlutterPlatform.Windows)) this.buildDownload(FlutterPlatform.Windows),
      if (this.app.hasPlatform(FlutterPlatform.Android)) ...[
        this.buildDownload(FlutterPlatform.Android),
        ...(this.app.platforms[FlutterPlatform.Android] as PlatformDownload)
            .subFiles
            .map((file) => this.buildDownload(FlutterPlatform.Android, file: file)),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(this.app.name.capitalize, style: Theme.of(context).textTheme.headline6),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            ),
            this.buildPlatforms(context),
            ExpansionTile(
              initiallyExpanded: this.expanded,
              title: Text('Other downloads'),
              expandedAlignment: Alignment.centerLeft,
              children: this.buildAllDownloads(),
            )
          ],
        ),
      ),
    );
  }
}
