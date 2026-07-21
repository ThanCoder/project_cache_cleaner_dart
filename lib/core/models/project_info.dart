import 'package:dart_core_extensions/dart_core_extensions.dart';

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

extension ProjectInfoExtensions on List<ProjectInfo> {
  void sortSize({bool big2Small = true}) {
    sort((a, b) {
      if (big2Small) {
        return b.totalCacheSize.compareTo(a.totalCacheSize);
      } else {
        return a.totalCacheSize.compareTo(b.totalCacheSize);
      }
    });
  }
}
