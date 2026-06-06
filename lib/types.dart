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
  dotnet,
  goCache,
  linuxCache,
  gradleCaches,
}

class ProjectInfo {
  final String name;
  final ProjectType type;
  int size;
  List<String> dirs;
  ProjectInfo({
    required this.name,
    required this.type,
    this.size = 0,
    required this.dirs,
  });

  String get sizeLable => size.fileSizeLabel();

  @override
  String toString() {
    return 'ProjectInfo(name: $name, type: ${type.name}, size: $size, dirs: $dirs)';
  }
}
