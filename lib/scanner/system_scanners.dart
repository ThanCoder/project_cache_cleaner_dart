import 'package:project_cache_cleaner/scanner/base_scanner.dart';

class GradleCacheScanner extends BaseSystemCacheScanner {
  @override
  String get cacheName => 'Gradle Cache';
  @override
  String get projectType => 'GradleCaches'; // သို့မဟုတ် ProjectType.gradleCaches
  @override
  String get relativePath => '.gradle/caches';
}

class LinuxCacheScanner extends BaseSystemCacheScanner {
  @override
  String get cacheName => 'Linux Cache';
  @override
  String get projectType => 'LinuxCache';
  @override
  String get relativePath => '.cache';
}

class GoCacheScanner extends BaseSystemCacheScanner {
  @override
  String get cacheName => 'Go Cache';

  @override
  String get projectType => 'GoCache';

  @override
  String get relativePath => '.go_cache';
}

class DartPubCacheScanner extends BaseSystemCacheScanner {
  @override
  String get cacheName => 'Dart Pub Cache';

  @override
  String get projectType => 'DartPubCache';

  @override
  String get relativePath => '.pub-cache';
}
