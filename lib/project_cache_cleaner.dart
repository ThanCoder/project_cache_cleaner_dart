import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:project_cache_cleaner/types.dart';
import 'package:project_cache_cleaner/utils.dart';

Future<List<ProjectInfo>> scanProjectCacheFolder(
  List<String> rootPaths, {
  bool includeEmptyCacheProject = false,
  bool includeOtherCache = true,
}) async {
  return await Isolate.run<List<ProjectInfo>>(() {
    final projects = <ProjectInfo>[];
    final homePath = Platform.environment['HOME'];

    for (var path in rootPaths) {
      final queue = [Directory(path)];
      // ရှိနေသမျှ loop လုပ်မယ်
      while (queue.isNotEmpty) {
        final currentDir = queue.removeLast();
        if (!currentDir.existsSync()) continue;

        try {
          final entities = currentDir.listSync(
            recursive: false,
            followLinks: false,
          );
          ProjectType projectType = .none;
          List<Directory> subFolders = [];
          List<String> cacheFolders = [];
          int totalCacheSize = 0;
          //search project type
          for (var entry in entities) {
            final name = entry.getName();
            if (entry.isFile) {
              if (name == 'pubspec.yaml') {
                projectType = .flutter;
              } else if (name == 'package.json') {
                // package.json ကို တွေ့ရင် Node.js project လို့ တိတိကျကျ သိနိုင်တယ်
                projectType = .nodejs;
              } else if (name == 'Cargo.toml') {
                projectType = ProjectType.rust; // Rust
              } else if (name == 'go.mod') {
                projectType = ProjectType.go; // Go
              } else if (name == 'requirements.txt' ||
                  name == 'pyproject.toml') {
                projectType = ProjectType.python; // Python
              } else if (name == 'build.zig') {
                projectType = ProjectType.zig; // ⚡ Zig Project အဖြစ် သတ်မှတ်မယ်
              } else if (name == 'vcpkg.json') {
                projectType = .cppVcpkg;
              } else if (name == 'basic.csproj') {
                projectType = .dotnet;
              }
              // folder
            } else if (entry.isDirectory) {
              subFolders.add(entry.directory);
            }

            //loop end
          }

          // flutter
          if (projectType == .flutter) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              //flutter
              if (dirName == '.dart_tool' || dirName == 'build') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (dirName == 'example') {
                // example folder တွေ့ရင် အထဲထဲထိ ဆက်ရှာဖို့ queue ထဲ ထည့်မယ်
                queue.add(folder);
              }
            }

            // add project
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }

            continue;
          }

          // ၃။ Node.js Project ဖြစ်ခဲ့ရင်
          if (projectType == ProjectType.nodejs) {
            for (var folder in subFolders) {
              final dirName = folder.getName();

              if (dirName == 'node_modules') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                // node_modules မဟုတ်တဲ့ တခြား sub-folder တွေကို queue ထဲ ဆက်ထည့်ပေးရမယ်
                // (ဒါမှ Node project အောက်က တခြားအလုပ်တွေကို လွတ်မသွားမှာ)
                queue.add(folder);
              }
            }

            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // 🦀 Rust Project ဖြစ်ခဲ့ရင်
          if (projectType == ProjectType.rust) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              if (dirName == 'target') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                queue.add(
                  folder,
                ); // target မဟုတ်တဲ့ တခြား folder တွေကို queue ထဲ ထည့်မယ်
              }
            }
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // 🐍 Python Project ဖြစ်ခဲ့ရင်
          if (projectType == ProjectType.python) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              // Python မှာက cache/venv တွေ အများကြီး ရှိနိုင်လို့ 'OR' ခံစစ်မယ်
              if (dirName == '__pycache__' ||
                  dirName == '.venv' ||
                  dirName == 'venv' ||
                  dirName == '.pytest_cache') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                queue.add(folder);
              }
            }
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // 🐹 Go Project ဖြစ်ခဲ့ရင်
          if (projectType == ProjectType.go) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              // Go ကတော့ များသောအားဖြင့် build ထွက်တဲ့ bin folder ပဲ ရှိတတ်ပါတယ်
              if (dirName == 'bin') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                queue.add(folder);
              }
            }
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // ⚡ Zig Project ဖြစ်ခဲ့ရင်
          if (projectType == ProjectType.zig) {
            for (var folder in subFolders) {
              final dirName = folder.getName();

              // .zig-cache နဲ့ zig-out folder တွေကို ဖမ်းမယ်
              if (dirName == '.zig-cache' || dirName == 'zig-out') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                // ကျန်တဲ့ src/ စတဲ့ folder တွေကို queue ထဲ ဆက်ထည့်မယ်
                queue.add(folder);
              }
            }

            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // Cpp vcpkg
          if (projectType == .cppVcpkg) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              if (dirName == 'out') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                queue.add(folder);
              }
            }
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          // Dotnet C#
          if (projectType == .dotnet) {
            for (var folder in subFolders) {
              final dirName = folder.getName();
              if (dirName == 'obj' || dirName == 'bin') {
                cacheFolders.add(folder.path);
                totalCacheSize += getFolderSize(folder);
              } else if (!dirName.startsWith('.')) {
                queue.add(folder);
              }
            }
            if (!includeEmptyCacheProject && totalCacheSize > 0) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            } else if (includeEmptyCacheProject) {
              projects.add(
                ProjectInfo(
                  name: currentDir.getName(),
                  type: projectType,
                  dirs: cacheFolders,
                  size: totalCacheSize,
                ),
              );
            }
            continue;
          }

          for (var dir in subFolders) {
            if (dir.getName().startsWith('.')) continue;
            queue.add(dir);
          }
        } catch (e) {
          print('Error: $e');
          continue;
        }
      }
    }

    if (!includeOtherCache) {
      return projects;
    }
    // cache
    projects.add(
      ProjectInfo(
        name: 'Go Cache',
        type: .goCache,
        dirs: [homePath!.join('.go_cache')],
        size: getFolderSize(Directory(homePath.join('.go_cache'))),
      ),
    );
    projects.add(
      ProjectInfo(
        name: 'Linux Cache',
        type: .linuxCache,
        dirs: [homePath.join('.cache')],
        size: getFolderSize(Directory(homePath.join('.cache'))),
      ),
    );
    projects.add(
      ProjectInfo(
        name: 'Gradle Cache',
        type: .gradleCaches,
        dirs: [homePath.join('.gradle').join('caches')],
        size: getFolderSize(Directory(homePath.join('.gradle').join('caches'))),
      ),
    );

    return projects;
  });
}
