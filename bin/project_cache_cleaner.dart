import 'dart:io';

import 'package:project_cache_cleaner/app_arg.dart';
import 'package:project_cache_cleaner/core/project_cache_scanner.dart';

void main(List<String> args) async {
  final homePath = Platform.environment['HOME'];
  bool includeOtherCache = false;
  bool includeEmptyCacheProject = false;
  try {
    final parser = appAargs;

    final result = parser.parse(args);

    if (args.isEmpty || result['help']) {
      print(parser.usage);
      return;
    }
    includeOtherCache = result['other-cache'] ?? false;
    includeEmptyCacheProject = result['include-empty-cache-project'] ?? false;
  } catch (e) {
    print('[AppAarg:Error]: $e');
    return;
  }

  // Screen ကို clear လုပ်ပြီး cursor ကို home position ရွှေ့မယ်
  stdout.write('\x1B[2J\x1B[0;0H');
  print('\nScanning started...');

  final scanner = ProjectCacheScanner(
    includeEmptyCacheProject: includeEmptyCacheProject,
    includeOtherCache: includeOtherCache,
  );

  print('\nWill Scan Project Types: ${scanner.scannerTypes.join(', ')}');
  // show system cache typs
  if (includeOtherCache && scanner.systemScannerTypes.isNotEmpty) {
    print(
      'Will Scan System Caches: ${scanner.systemScannerTypes.join(', ')} \n',
    );
  }
  if (includeEmptyCacheProject) {
    print('Will Add Empty Cache Project....');
  }
  final stopwatch = Stopwatch()..start();

  final rootPaths = ['$homePath/projects', '$homePath/Documents'];

  await scanner.scan(rootPaths);

  scanner.showTable(stopwatch.elapsed);
}
