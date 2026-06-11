import 'package:dart_core_extensions/dart_core_extensions.dart';

enum ProjectType {
  none,
  flutter,
  nodejs,
  rust,
  go,
  python,
  zig,
  cppVcpkg,
  cppCmake,
  dotnet,
  goCache,
  linuxCache,
  gradleCaches,
}

class ProjectInfo {
  final String name;
  final String type;
  int totalCacheSize;
  List<String> cacheFolders;
  ProjectInfo({
    required this.name,
    required this.type,
    this.totalCacheSize = 0,
    required this.cacheFolders,
  });

  String get totalCacheSizeLable => totalCacheSize.fileSizeLabel();

  @override
  String toString() {
    return 'ProjectInfo(name: $name, type: $type, totalCacheSize: $totalCacheSize, cacheFolders: $cacheFolders)';
  }
}
