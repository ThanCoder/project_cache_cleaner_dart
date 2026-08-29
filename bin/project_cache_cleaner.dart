import 'dart:io';

import 'package:project_cache_cleaner/app_arg.dart';
import 'package:project_cache_cleaner/project_cache_scanner.dart';

void main(List<String> args) async {
  final homePath = Platform.environment['HOME'];
  bool systemCacheOnly = false;
  bool projectCacheOnly = false;
  bool includeEmptyCacheProject = false;
  try {
    final parser = appAargs;

    final result = parser.parse(args);

    if (args.isEmpty || result['help']) {
      print(parser.usage);
      return;
    }

    systemCacheOnly = result['system-cache-only'] ?? false;
    projectCacheOnly = result['project-cache-only'] ?? false;
    includeEmptyCacheProject = result['include-empty-cache-project'] ?? false;
  } catch (e) {
    print('[AppAarg:Error]: $e');
    return;
  }

  // Screen ကို clear လုပ်ပြီး cursor ကို home position ရွှေ့မယ်
  stdout.write('\x1B[2J\x1B[0;0H');
  print('\nScanning started...');

  //test
  // print('systemCacheOnly: $systemCacheOnly');
  // print('projectCacheOnly: $projectCacheOnly');
  // return;

  final scanner = ProjectCacheScanner(
    includeEmptyCacheProject: includeEmptyCacheProject,
    systemCacheOnly: systemCacheOnly,
    projectCacheOnly: projectCacheOnly,
  );

  if (includeEmptyCacheProject) {
    print('Will Add Empty Cache Project....');
  }
  final stopwatch = Stopwatch()..start();

  final rootPaths = ['$homePath/projects', '$homePath/Documents'];

  await scanner.scan(rootPaths);

  scanner.showTable(stopwatch.elapsed);
}
