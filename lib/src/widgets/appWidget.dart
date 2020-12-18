import 'package:apphub/src/app.dart';
import 'package:apphub/src/webUtils/webUtils.dart';
import 'package:flutter/material.dart';

import 'package:apphub/src/utils.dart';

class AppWidget extends StatefulWidget {
  final App app;
  final WebUtils utils;

  AppWidget(this.app, this.utils);

  @override
  State<StatefulWidget> createState() {
    return AppWidgetState(this.app.main);
  }
}

class AppWidgetState extends State<AppWidget> {
  AppVersion current;

  AppWidgetState(this.current);

  WebUtils get _utils => this.widget.utils;

  App get _app => this.widget.app;

  Widget _buildWebIcon(double size) {
    String browser = this._utils.getBrowser();
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
    return this._utils.open(this._app.webUrl, this._app.name);
  }

  void _download(EnvFile file) {
    return this._utils.download(file.url, file.name);
  }

  Widget buildDownload(EnvVersion version, {EnvFile file}) {
    EnvFile target = file;
    if (target == null) {
      target = version.main;
    }
    String name;
    if (this.current != this._app.main) {
      name = '(${this.current.version})';
    }
    if (file != null) {
      String fileName = '${file.name} ${file.mbytes.toStringAsFixed(2)} MB';
      if (name != null) {
        name += ' ' + fileName;
      } else {
        name = fileName;
      }
    }
    return Padding(
      padding: EdgeInsets.all(5),
      child: RaisedButton(
        onPressed: () => this._download(target),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              SizedBox(height: 25, width: 25, child: Image.asset('assets/browsers/${version.platform.name.toLowerCase()}.png')),
              SizedBox(width: 10),
              if (name != null) Flexible(child: Text(name)),
              if (name != null) SizedBox(width: 10),
              Icon(Icons.file_download, size: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlatforms(BuildContext context) {
    Env sysPlat = this._utils.getSupportedPlatform();
    return Row(
      children: [
        if (this._app.webUrl != null)
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
        if (this.current.platforms.containsKey(sysPlat)) this.buildDownload(this.current.platforms[sysPlat]),
      ],
    );
  }

  List<Widget> buildAllDownloads() {
    return this
        .current
        .platforms
        .values
        .map((version) => version.files.map((file) => this.buildDownload(version, file: file)))
        .expand((e) => e)
        .toList();
  }

  Widget getVersionSelector() {
    if (this._app.version.length > 1) {
      return Padding(
        padding: EdgeInsets.only(right: 25),
        child: DropdownButton<AppVersion>(
          value: this.current,
          icon: Icon(Icons.arrow_downward),
          onChanged: (newValue) => this.setState(() => this.current = newValue),
          items: this
              ._app
              .version
              .map((version) => DropdownMenuItem<AppVersion>(value: version, child: Text(version.version.toString())))
              .toList(),
        ),
      );
    } else {
      return Container();
    }
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(this._app.name.capitalize, style: Theme.of(context).textTheme.headline6),
                  this.getVersionSelector(),
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            ),
            this.buildPlatforms(context),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('All downloads'),
              expandedAlignment: Alignment.centerLeft,
              children: this.buildAllDownloads(),
            )
          ],
        ),
      ),
    );
  }
}
