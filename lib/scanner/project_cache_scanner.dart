// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cli_table/cli_table.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:project_cache_cleaner/scanner/base_scanner.dart';
import 'package:project_cache_cleaner/scanner/scanners.dart';
import 'package:project_cache_cleaner/scanner/system_scanners.dart';
import 'package:project_cache_cleaner/types.dart';
import 'package:project_cache_cleaner/utils.dart';

class ProjectCacheScanner {
  final bool includeEmptyCacheProject;
  final bool includeOtherCache;
  ProjectCacheScanner({
    required this.includeEmptyCacheProject,
    required this.includeOtherCache,
  });

  final List<BaseScanner> scannerList = [
    FlutterScanner(),
    NodejsScanner(),
    CppVcpkgScanner(),
    CppCMakeScanner(),
    DotnetScanner(),
    GoScanner(),
    PythonScanner(),
    RustScanner(),
    ZigScanner(),
  ];
  final List<BaseSystemCacheScanner> systemScannerList = [
    LinuxCacheScanner(),
    GradleCacheScanner(),
    GoCacheScanner(),
    DartPubCacheScanner(),
  ];

  List<String> get scannerTypes =>
      scannerList.map((e) => '[${e.projectType}]').toList();

  List<String> get systemScannerTypes =>
      systemScannerList.map((e) => '[${e.projectType}]').toList();

  final List<ProjectInfo> projectInfoList = [];

  Future<void> scan(List<String> rootPaths) async {
    if (scannerList.isEmpty) {
      print("Scanner Is Empty!!!");
      return;
    }
    for (var path in rootPaths) {
      final queue = [Directory(path)];

      while (queue.isNotEmpty) {
        final currentDir = queue.removeLast();
        if (!currentDir.existsSync()) continue;
        try {
          final entries = currentDir.listSync(
            followLinks: false,
            recursive: false,
          );

          BaseScanner? detectedScanner;
          List<Directory> subFolders = [];

          for (var entry in entries) {
            final name = entry.getName();
            // project package name ကိုစစ်မယ်
            if (entry.isFile) {
              for (var scanner in scannerList) {
                if (scanner.isMatch(name)) {
                  detectedScanner = scanner;
                }
              }
            } else if (entry.isDirectory) {
              // dir
              subFolders.add(entry.directory);
            }
          }

          // scanner ရှိလားစစ်မယ်
          if (detectedScanner != null) {
            final projectInfo = detectedScanner.process(
              currentDir,
              subFolders,
              includeEmptyCacheProject,
            );
            if (projectInfo != null) {
              projectInfoList.add(projectInfo);
            }
            // သူ့ရဲ့ subfolder တွေကို queue ထဲထည့်မလား စစ်မယ်
            for (var sub in subFolders) {
              if (detectedScanner.shouldQueueSubFolder(sub.getName())) {
                queue.add(sub);
              }
            }
            // project ရှာတွေ့ရင် အောက်ဘက်က queue ကိုပေးမသွားတော့ဘူး
            continue;
          }
          // sub folder တွေကို queue ထဲထည့်မယ်
          for (var sub in subFolders) {
            // hidden တွေကို မထည့်ဘူး
            if (sub.getName().startsWith('.')) continue;
            queue.add(sub);
          }
        } catch (e) {
          print('Error: $e');
          continue;
        }
      }
    }

    await _scanSystemCache();
  }

  Future<void> _scanSystemCache() async {
    final homePath = Platform.environment['HOME'];
    if (!includeOtherCache && homePath != null) return;
    for (var sysScanner in systemScannerList) {
      final info = sysScanner.process(homePath!);
      if (info != null) {
        projectInfoList.add(info);
      }
    }
  }

  void showTable(Duration elapsedTime) {
    if (projectInfoList.isEmpty) {
      print('\n✨ No cleanable cache projects found.');
      return;
    }

    final table = Table(header: ["Index", "Name", "Type", 'Size']);
    int allSize = 0;
    int i = 0;
    for (var pro in projectInfoList) {
      table.add([i, pro.name, pro.type, pro.totalCacheSizeLable]);
      allSize += pro.totalCacheSize;
      i++;
    }
    print('\n');
    print(table);
    print('\nScanning finished in ${elapsedTime.autoTimeLabel()}\n');
    print('All Size: ${allSize.fileSizeLabel()}\n');

    showPromptForDeletion();
  }

  void showPromptForDeletion() {
    // 2. Interactive prompt for deletion
    print('⚠️  Do you want to clean up these cache folders?');
    print(' [1] Clean All (Delete all detected caches)');
    print(' [2] Interactive Mode (Choose project one by one)');
    print(' [3] Clean With Project Index (example 1,2,3,4,5...etc)');
    print(' [4] Cancel & Exit');
    stdout.write('👉 Enter your choice (1/2/3,4): ');

    final choice = stdin.readLineSync()?.trim();

    // 3. Process the user's choice
    if (choice == '1') {
      stdout.write(
        '\n❗ Are you absolutely sure you want to delete ALL caches? (y/N): ',
      );
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      if (confirm == 'y' || confirm == 'yes') {
        deleteAllCaches(projectInfoList);
      } else {
        print('❌ Deletion cancelled.');
      }
    } else if (choice == '2') {
      deleteInteractive(projectInfoList);
    } else if (choice == '3') {
      print('Write Index Number: (example 1,2,3,4,5...etc)');
      final indexListString = stdin.readLineSync()?.trim();
      if (indexListString == null) return;
      final indexList = indexListString.split(',');
      deleteWithIndex(projectInfoList, indexList);
    } else {
      print('👋 Exited without deleting anything.');
    }
  }
}
