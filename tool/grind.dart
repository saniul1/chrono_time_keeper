import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:yaml/yaml.dart';

main(args) => grind(args);

@DefaultTask('Build the project.')
build() async {
  log("Building...");
  run('flutter', arguments: [
    'build',
    'macos',
    '--flavor',
    'prod',
    '-t',
    'lib/main_prod.dart',
    ' --release'
  ]);
  final oldAppFile =
      Directory('build/macos/Build/Products/Release-prod/Runner.app');

  // Read the current app version from pubspec.yaml
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  final version = pubspec['version'] as String;

  final dir = Directory('releases/$version/');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final newAppFile = Directory('${dir.path}/Chrono.app');
  oldAppFile.renameSync(newAppFile.path);
}
