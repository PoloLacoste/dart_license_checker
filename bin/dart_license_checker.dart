import 'dart:convert';
import 'dart:io';

// pana is not exporting license
import 'package:pana/src/license.dart';

// not importing pana due to http import errors
import 'package:pana/src/model.dart';
import 'package:pana/src/pubspec.dart';

import 'package:barbecue/barbecue.dart';
import 'package:tint/tint.dart';

void main(List<String> arguments) async {
  final showTransitiveDependencies =
      arguments.contains('--show-transitive-dependencies');
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml file not found in current directory'.red());
    exit(1);
  }

  final pubspec = Pubspec.parseYaml(pubspecFile.readAsStringSync());

  final packageConfigFile = File('.dart_tool/package_config.json');

  if (!pubspecFile.existsSync()) {
    stderr.writeln(
        '.dart_tool/package_config.json file not found in current directory. You may need to run "flutter pub get" or "pub get"'
            .red());
    exit(1);
  }

  print('Checking dependencies...'.blue());

  final packageConfig = json.decode(packageConfigFile.readAsStringSync());

  final rows = <Row>[];

  for (final package in packageConfig['packages']) {
    final name = package['name'];

    if (!showTransitiveDependencies) {
      if (!pubspec.dependencies.containsKey(name)) {
        continue;
      }
    }

    String rootUri = package['rootUri'];
    if (rootUri.startsWith('file://')) {
      rootUri = rootUri.substring(7);
    }

    final license = await detectLicenseInDir(rootUri);

    if (license != null) {
      rows.add(Row(cells: [
        Cell(name,
            style: CellStyle(
              alignment: TextAlignment.TopRight,
            )),
        Cell(formatLicenseName(license)),
      ]));
    } else {
      rows.add(Row(cells: [
        Cell(name,
            style: CellStyle(
              alignment: TextAlignment.TopRight,
            )),
        Cell('No license file'.grey()),
      ]));
    }
  }
  print(
    Table(
      tableStyle: TableStyle(
        border: true,
      ),
      header: TableSection(
        rows: [
          Row(
            cells: [
              Cell(
                'Package Name  '.bold(),
                style: CellStyle(
                  alignment: TextAlignment.TopRight,
                ),
              ),
              Cell('License'.bold()),
            ],
            cellStyle: CellStyle(
              borderBottom: true,
            ),
          ),
        ],
      ),
      body: TableSection(
        cellStyle: CellStyle(
          paddingRight: 2,
        ),
        rows: rows,
      ),
    ).render(),
  );

  exit(0);
}

String formatLicenseName(LicenseFile license) {
  if (license.name == 'unknown') {
    return 'Unknown'.red();
  } else if (copyleftOrProprietaryLicenses.indexWhere((name) => license.name.startsWith(name)) != -1) {
    return license.shortFormatted.red();
  } else if (permissiveLicenses.indexWhere((name) => license.name.startsWith(name)) != -1) {
    return license.shortFormatted.green();
  } else {
    return license.shortFormatted.yellow();
  }
}

// TODO LGPL, AGPL, MPL

const permissiveLicenses = [
  'MIT',
  'BSD',
  'Apache',
  'Unlicense',
];

const copyleftOrProprietaryLicenses = [
  'GPL',
];
