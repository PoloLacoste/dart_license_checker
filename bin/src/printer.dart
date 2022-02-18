import 'dart:io';

import 'package:barbecue/barbecue.dart';
import 'package:pana/models.dart';
import 'package:tint/tint.dart';

import 'utils.dart';

class Printer {
  final List<Row> _rows = [];

  void addLicense(String name, LicenseFile license) {
    _rows.add(Row(
      cells: [
        Cell(
          name,
          style: CellStyle(
            alignment: TextAlignment.TopRight,
          ),
        ),
        Cell(formatLicenseName(license)),
      ],
    ));
  }

  void addNoLicense(String name) {
    _rows.add(Row(
      cells: [
        Cell(
          name,
          style: CellStyle(
            alignment: TextAlignment.TopRight,
          ),
        ),
        Cell(noLicenseFile.grey()),
      ],
    ));
  }

  void print() {
    final table = Table(
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
        rows: _rows,
      ),
    );
    stdout.writeln(table.render());
  }
}
