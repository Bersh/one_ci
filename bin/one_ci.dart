import 'dart:io';

import 'package:one_ci/repo_type.dart';

const String branchMaster = 'master';
const String branchMain = 'main';

void main(List<String> arguments) async {
  RepoType repoType = arguments.isEmpty || arguments[0] == 'github'
      ? RepoType.github
      : RepoType.gitlab;
  print(repoType);

  String mainBranch = await getMainBranch();
  print(mainBranch);

  if (repoType == RepoType.github) {
    await Directory('.github/workflows').create(recursive: true);
  }
  File ciFile = repoType.ciFile;

  if (ciFile.existsSync()) {
    print('Error: CI file exists');
  } else {
    ciFile.writeAsString(repoType.getCiString(mainBranch));
  }
}

Future<String> getMainBranch() async {
  ProcessResult processResult = await Process.run('git', ['branch']);
  String gitOutput = processResult.stdout.toString();
  if (gitOutput.contains(branchMaster)) {
    return branchMaster;
  } else if (gitOutput.contains(branchMain)) {
    return branchMain;
  }
  throw Exception('Main branch not found');
}
