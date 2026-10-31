import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef _BundledLicense = ({String package, String asset});

const List<_BundledLicense> _kNastaleeqLicenses = [
  (
    package: 'DigitalKhatt IndoPak font',
    asset: 'assets/fonts/DigitalKhattIndoPak-OFL.txt',
  ),
  (
    package: 'DigitalKhatt IndoPak Quran text',
    asset: 'assets/quran/indopak-digitalkhatt-LICENSE.txt',
  ),
  (
    package: 'KFGQPC Hafs Nastaleeq font',
    asset: 'assets/fonts/HafsNastaleeq-LICENSE.txt',
  ),
  (
    package: 'KFGQPC Hafs Nastaleeq Quran text',
    asset: 'assets/quran/indopak-kfgqpc-NOTICE.txt',
  ),
];

Stream<LicenseEntry> _loadNastaleeqLicenses() async* {
  for (final license in _kNastaleeqLicenses) {
    final text = await rootBundle.loadString(license.asset, cache: false);
    yield LicenseEntryWithLineBreaks([license.package], text);
  }
}

void registerNastaleeqLicenses() =>
    LicenseRegistry.addLicense(_loadNastaleeqLicenses);
