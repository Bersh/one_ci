import 'dart:io';

import 'package:one_ci/github.dart';

const String branchMaster = 'master';
const String branchMain = 'main';

void main(List<String> arguments) async {
  await Directory('.github/workflows').create(recursive: true);
  File ciFile = File('.github/workflows/ci.yaml');
  String mainBranch = await getMainBranch();
  print(mainBranch);
  if (ciFile.existsSync()) {
    print('CI file exists');
  } else {
    ciFile.writeAsString(Github.getCiString(mainBranch));
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
