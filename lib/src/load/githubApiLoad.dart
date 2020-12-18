import 'package:github/github.dart';

import 'package:apphub/src/app.dart';
import 'package:version/version.dart';

final _auth = Authentication.withToken('180ae90a10dc9bde1cf61d1aa51150e1d1a4e202');
final _github = GitHub(auth: _auth);

const platformExt = {
  Env.Android: '.apk',
  Env.Windows: '.windows.zip',
};

EnvFile _getFile(ReleaseAsset asset) {
  return EnvFile(asset.name, asset.size / (1024 * 1024), asset.browserDownloadUrl);
}

AppVersion _buildVersion(Release release) {
  Version version = Version.parse(release.tagName);
  List<EnvFile> files = release.assets.map<EnvFile>(_getFile).toList();

  final platforms = platformExt.map<Env, EnvVersion>((platform, ext) {
    List<EnvFile> platformFiles = files.where((file) => file.name.endsWith(ext)).toList();
    return MapEntry(
      platform,
      EnvVersion(
        platform,
        platformFiles.firstWhere((file) => !file.name.contains('-')),
        platformFiles,
      ),
    );
  });

  return AppVersion(version, release.publishedAt, platforms);
}

Future<App> _getApp(Repository repository) async {
  String webUrl;
  if (repository.hasPages) {
    webUrl = 'https://${repository.owner.login}.github.io/${repository.name}/';
  }

  final releases = await _github.repositories.listReleases(repository.slug()).toList();

  final versions = releases.map(_buildVersion).toList();

  versions.sort((v1, v2) => v2.version.compareTo(v1.version));

  return App(repository.name, webUrl, versions.first, versions);
}

class RepositoryDef {
  final String owner;
  final String name;

  RepositoryDef(this.owner, this.name);
}

Future<List<App>> githubApps(List<RepositoryDef> repositories) async {
  final slugs = repositories.map<RepositorySlug>((repoDef) => RepositorySlug(repoDef.owner, repoDef.name)).toList();

  final repos = await _github.repositories.getRepositories(slugs).toList();

  return Future.wait(repos.map(_getApp));
}
