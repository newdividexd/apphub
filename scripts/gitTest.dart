import 'package:github/github.dart';

void test() async {
  final _github = GitHub();

  final testYes = await _github.repositories.getRepository(RepositorySlug('newdividexd', 'juggernaut'));
  final testNo = await _github.repositories.getRepository(RepositorySlug('JuanCouste', 'github.dart'));

  print(testYes.hasPages);
  print(testNo.hasPages);
}

void main() {
  test();
}
