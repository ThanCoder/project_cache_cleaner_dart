import 'package:project_cache_cleaner/scanner/base_scanner.dart';

class FlutterScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['.dart_tool', 'build'];

  @override
  bool isMatch(String testName) => testName == 'pubspec.yaml';

  @override
  bool shouldQueueSubFolder(String dirname) {
    return dirname == 'example';
  }

  @override
  String get projectType => 'Flutter';
}

class NodejsScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['node_modules'];

  @override
  bool isMatch(String testName) => testName == 'package.json';

  @override
  String get projectType => 'NodeJs';
}

class RustScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['target'];

  @override
  bool isMatch(String testName) => testName == 'Cargo.toml';

  @override
  String get projectType => 'Rust';
}

class PythonScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => [
    '__pycache__',
    '.venv',
    'venv',
    '.pytest_cache',
  ];

  @override
  bool isMatch(String testName) =>
      testName == 'requirements.txt' || testName == 'pyproject.toml';

  @override
  String get projectType => 'Python';
}

class GoScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['bin', 'build'];

  @override
  bool isMatch(String testName) => testName == 'go.mod';

  @override
  String get projectType => 'Go';
}

class ZigScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['.zig-cache', 'zig-out'];

  @override
  bool isMatch(String testName) => testName == 'build.zig';

  @override
  String get projectType => 'Zig';
}

class CppVcpkgScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['out', 'build'];

  @override
  bool isMatch(String testName) => testName == 'vcpkg.json';

  @override
  String get projectType => 'Cpp Vcpkg';
}

class DotnetScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['obj', 'bin'];

  @override
  bool isMatch(String testName) => testName.endsWith('.csproj');

  @override
  String get projectType => 'DotNet';
}

class CppCMakeScanner extends BaseScanner {
  @override
  List<String> get cacheFolderNames => ['build'];

  @override
  bool isMatch(String testName) => testName == 'CMakeLists.txt';

  @override
  String get projectType => 'Cpp Cmake';
}
