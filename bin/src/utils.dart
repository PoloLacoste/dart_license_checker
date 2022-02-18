import 'package:pana/models.dart';
import 'package:tint/tint.dart';

const showTransitiveDependenciesFlag = 'show-transitive-dependencies';
const outputTypeOption = 'output-type';
const outputOption = 'output';
const helpFlag = 'help';

const noLicenseFile = 'No license file';

const permissiveLicenses = [
  'MIT',
  'BSD',
  'Apache',
  'MPL',
  'Zlib',
  'Unlicense',
];

const copyleftOrProprietaryLicenses = [
  'GPL',
  'LGPL',
  'AGPL',
];

bool isCopyleftOrProprietaryLicenses(LicenseFile license) {
  final index = copyleftOrProprietaryLicenses
      .indexWhere((name) => license.name.startsWith(name));
  return index != -1;
}

bool isPermissiveLicenses(LicenseFile license) {
  final index =
      permissiveLicenses.indexWhere((name) => license.name.startsWith(name));
  return index != -1;
}

String formatLicenseName(LicenseFile license) {
  if (license.name == 'unknown') {
    return 'Unknown'.red();
  } else if (isPermissiveLicenses(license)) {
    return license.shortFormatted.green();
  } else if (isCopyleftOrProprietaryLicenses(license)) {
    return license.shortFormatted.red();
  } else {
    return license.shortFormatted.yellow();
  }
}

const greyColor = '#9E9E9E';
const redColor = '#F44336';
const greenColor = '#4CAF50';
const yellowColor = '#FFEB3B';

String getLicenseColor(LicenseFile license) {
  if (license.name == 'unknown' || isCopyleftOrProprietaryLicenses(license)) {
    return redColor;
  } else if (isPermissiveLicenses(license)) {
    return greenColor;
  } else {
    return yellowColor;
  }
}