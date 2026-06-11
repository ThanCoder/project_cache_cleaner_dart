import 'dart:io';

import 'package:project_cache_cleaner/app_arg.dart';
import 'package:project_cache_cleaner/scanner/project_cache_scanner.dart';

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

// Future<void> cleanOldMethod(
//   List<String> rootPaths,
//   bool includeOtherCache,
//   bool includeEmptyCacheProject,
// ) async {
//   final stopwatch = Stopwatch()..start();

//   final projects = await scanProjectCacheFolder(
//     rootPaths,
//     includeOtherCache: includeOtherCache,
//     includeEmptyCacheProject: includeEmptyCacheProject,
//   );

//   if (projects.isEmpty) {
//     print('✨ No cleanable cache projects found.');
//     return;
//   }

//   final table = Table(header: ["Index", "Name", "Type", 'Size']);
//   int allSize = 0;
//   int i = 0;
//   for (var pro in projects) {
//     table.add([i, pro.name, pro.type.name, pro.totalCacheSizeLable]);
//     allSize += pro.totalCacheSize;
//     i++;
//   }

//   print(table);

//   print('\nScanning finished in ${stopwatch.elapsed}ms\n');
//   print('All Size: ${allSize.fileSizeLabel()}\n');

//   // 2. Interactive prompt for deletion
//   print('⚠️  Do you want to clean up these cache folders?');
//   print(' [1] Clean All (Delete all detected caches)');
//   print(' [2] Interactive Mode (Choose project one by one)');
//   print(' [3] Clean With Project Index (example 1,2,3,4,5...etc)');
//   print(' [4] Cancel & Exit');
//   stdout.write('👉 Enter your choice (1/2/3,4): ');

//   final choice = stdin.readLineSync()?.trim();

//   // 3. Process the user's choice
//   if (choice == '1') {
//     stdout.write(
//       '\n❗ Are you absolutely sure you want to delete ALL caches? (y/N): ',
//     );
//     final confirm = stdin.readLineSync()?.trim().toLowerCase();
//     if (confirm == 'y' || confirm == 'yes') {
//       deleteAllCaches(projects);
//     } else {
//       print('❌ Deletion cancelled.');
//     }
//   } else if (choice == '2') {
//     deleteInteractive(projects);
//   } else if (choice == '3') {
//     print('Write Index Number: (example 1,2,3,4,5...etc)');
//     final indexListString = stdin.readLineSync()?.trim();
//     if (indexListString == null) return;
//     final indexList = indexListString.split(',');
//     deleteWithIndex(projects, indexList);
//   } else {
//     print('👋 Exited without deleting anything.');
//   }
// }
