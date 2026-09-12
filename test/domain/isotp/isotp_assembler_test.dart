import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/domain/isotp/isotp_assembler.dart';
import 'package:odb_dashboard/domain/isotp/isotp_types.dart';

void main() {
  group('IsotpAssembler', () {
    test('parse and feed single frame Mode 01 RPM response', () {
      // SF len=4: 41 0C 2E E0  (3000 RPM)
      final data = [0x04, 0x41, 0x0C, 0x2E, 0xE0, 0, 0, 0];
      final frame = IsotpAssembler.parseFrame(data);
      expect(frame, isA<IsotpSingleFrame>());
      final sf = frame! as IsotpSingleFrame;
      expect(sf.length, 4);
      expect(sf.payload, [0x41, 0x0C, 0x2E, 0xE0]);

      final asm = IsotpAssembler();
      final msg = asm.feed(data, canId: IsotpAddress.response);
      expect(msg, isNotNull);
      expect(msg!.payload, [0x41, 0x0C, 0x2E, 0xE0]);
      expect(msg.canId, IsotpAddress.response);
    });

    test('encode short payload as single frame', () {
      final frames = IsotpAssembler.encode([0x01, 0x0C]);
      expect(frames, hasLength(1));
      expect(frames.first[0], 0x02);
      expect(frames.first[1], 0x01);
      expect(frames.first[2], 0x0C);
    });

    test('assemble FF + CF multi-frame', () {
      // Total length 10: first 6 in FF, remaining 4 in CF
      final payload = List<int>.generate(10, (i) => i + 1);
      final encoded = IsotpAssembler.encode(payload);
      expect(encoded.length, greaterThan(1));
      expect(IsotpAssembler.needsPeerFlowControl(payload), isTrue);

      final asm = IsotpAssembler();
      expect(asm.feed(encoded[0]), isNull);
      expect(asm.needsFlowControl, isTrue);
      expect(asm.isAssembling, isTrue);

      final msg = asm.feed(encoded[1]);
      expect(msg, isNotNull);
      expect(msg!.payload, payload);
      expect(asm.isAssembling, isFalse);
    });

    test('buildFlowControl CTS', () {
      final fc = IsotpAssembler.buildFlowControl();
      expect(fc[0], 0x30);
      expect(fc[1], 0);
      expect(fc[2], 0);
    });

    test('rejects bad sequence on CF', () {
      final asm = IsotpAssembler();
      // FF total 10
      asm.feed([0x10, 0x0A, 1, 2, 3, 4, 5, 6]);
      // Wrong seq (2 instead of 1)
      final msg = asm.feed([0x22, 7, 8, 9, 10, 0, 0, 0]);
      expect(msg, isNull);
      expect(asm.isAssembling, isFalse);
    });
  });
}
