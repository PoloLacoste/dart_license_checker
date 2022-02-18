import 'dart:io';

import 'package:excel/excel.dart';
import 'package:pana/models.dart';

import 'utils.dart';

enum WriterType {
  csv,
  xlsx,
  none,
}

class Writer {
  Writer({
    required this.output,
    required this.packageName,
    required this.type,
  });

  final String? output;
  final String packageName;
  final WriterType type;
  late final bool canWrite = type != WriterType.none;
  late final File _outputFile =
      File('${output ?? '${packageName}_licenses'}.${type.name}');
  final _excel = Excel.createExcel();

  Future<void> initialize() async {
    if (await _outputFile.exists()) {
      await _outputFile.delete();
    }
  }

  Future<void> writeLicense(String name, LicenseFile license, int index) async {
    switch (type) {
      case WriterType.csv:
        final licenseName = license.shortFormatted == 'unknown'
            ? 'Unknown'
            : license.shortFormatted;
        await _outputFile.writeAsString(
          '$name,$licenseName\n',
          mode: FileMode.append,
        );
        break;
      case WriterType.xlsx:
        final licenseName = license.shortFormatted == 'unknown'
            ? 'Unknown'
            : license.shortFormatted;
        final sheet = _excel.sheets[_excel.getDefaultSheet()];
        final cellName = sheet!.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: index,
        ));
        cellName.value = name;
        final cellLicense = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: index,
        ));
        cellLicense.cellStyle = CellStyle(
          fontColorHex: getLicenseColor(license),
        );
        cellLicense.value = licenseName;
        break;
      default:
        break;
    }
  }

  Future<void> writeNoLicense(
    String name,
    int index,
  ) async {
    switch (type) {
      case WriterType.csv:
        await _outputFile.writeAsString(
          '$name,$noLicenseFile\n',
          mode: FileMode.append,
        );
        break;
      case WriterType.xlsx:
        final sheet = _excel.sheets[_excel.getDefaultSheet()];
        final cellName = sheet!.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: index,
        ));
        cellName.value = name;
        final cellLicense = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: index,
        ));
        cellLicense.cellStyle = CellStyle(
          fontColorHex: greyColor,
        );
        cellLicense.value = noLicenseFile;
        break;
      default:
        break;
    }
  }

  Future<void> save() async {
    switch (type) {
      case WriterType.xlsx:
        final bytes = _excel.save();
        await _outputFile.writeAsBytes(bytes!);
        break;
      default:
        break;
    }
  }
}
