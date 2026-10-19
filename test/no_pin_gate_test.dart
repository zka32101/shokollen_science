import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 保護者ゲートに、固定の暗証番号(PIN)式の `ParentalGateService` を使わないことを守る。
/// 子どもでも推測しやすいため、かけ算のゲート(lib/widgets/parental_gate.dart)に統一している。
void main() {
  test('lib 配下で PIN 式の ParentalGateService を使っていない', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is File && f.path.endsWith('.dart')) {
        if (f.readAsStringSync().contains('ParentalGateService')) {
          offenders.add(f.path);
        }
      }
    }
    expect(offenders, isEmpty, reason: 'PIN式のゲートが残っている: $offenders');
  });
}
