import 'dart:convert';
import 'dart:io';

// pana is not exporting license
import 'package:pana/src/license.dart';

// not importing pana due to http import errors
import 'package:pana/src/pubspec.dart';

import 'package:args/args.dart';
import 'package:tint/tint.dart';

import 'src/writer.dart';
import 'src/printer.dart';
import 'src/utils.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addFlag(
    showTransitiveDependenciesFlag,
    defaultsTo: false,
    help: 'Analyze transitive dependencies',
  );
  parser.addOption(
    outputTypeOption,
    abbr: 't',
    allowed: [
      WriterType.csv.name,
      WriterType.xlsx.name,
    ],
    defaultsTo: WriterType.none.name,
    help: 'Output type',
  );
  parser.addOption(
    outputOption,
    abbr: 'o',
    defaultsTo: null,
    help: 'Output file path (without type extension), default to "CurrentPackageName_licenses"',
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
  );
  try {
    final args = parser.parse(arguments);
    if (args.wasParsed(helpFlag)) {
      print('Dart license checker:');
      print(parser.usage);
      exit(0);
    }
    licenseChecker(args);
  } catch (e) {
    stderr.writeln(e.toString().red());
    exit(1);
  }
}

void licenseChecker(ArgResults args) async {
  final showTransitiveDependencies =
      args[showTransitiveDependenciesFlag] as bool;
  final outputType = WriterType.values.byName(args[outputTypeOption] as String);
  final output = args[outputOption] as String?;

  print('Checking pubspec and package_config files...'.blue());

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml file not found in current directory'.red());
    exit(1);
  }

  final packageConfigFile = File('.dart_tool/package_config.json');
  if (!packageConfigFile.existsSync()) {
    stderr.writeln(
        '.dart_tool/package_config.json file not found in current directory.'
                'You may need to run "flutter pub get" or "pub get"'
            .red());
    exit(1);
  }

  final pubspec = Pubspec.parseYaml(pubspecFile.readAsStringSync());
  final packageConfig = json.decode(packageConfigFile.readAsStringSync());

  print('Checking dependencies...'.blue());

  final printer = Printer();
  final writer = Writer(
    output: output,
    packageName: pubspec.name,
    type: outputType,
  );
  await writer.initialize();

  var index = 0;
  for (final package in packageConfig['packages']) {
    final name = package['name'];

    if (!showTransitiveDependencies) {
      if (!pubspec.dependencies.containsKey(name)) {
        continue;
      }
    }

    String rootUri = package['rootUri'];
    if (rootUri.startsWith('file://')) {
      rootUri = rootUri.substring(8);
    }

    final license = await detectLicenseInDir(rootUri);

    if (license != null) {
      printer.addLicense(name, license);
      await writer.writeLicense(name, license, index);
    } else {
      printer.addNoLicense(name);
      await writer.writeNoLicense(name, index);
    }
    index++;
  }
  printer.print();
  await writer.save();

  exit(0);
}
