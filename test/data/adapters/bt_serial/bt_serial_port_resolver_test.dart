import 'package:flutter_test/flutter_test.dart';
import 'package:odb_dashboard/data/adapters/bt_serial/bt_serial_port_resolver.dart';

void main() {
  group('BtSerialPortResolver', () {
    test('env OBD_COM_PORT wins over auto-detect', () {
      final resolver = BtSerialPortResolver(
        envReader: (key) => key == 'OBD_COM_PORT' ? 'com7' : null,
        listPorts: () => const [
          BtSerialDetectedPort(
            portName: 'COM3',
            friendlyName: 'ELM327',
            hardwareID: 'BTHENUM\\{00001101}',
          ),
        ],
      );

      // definedPort is compile-time; when unset, env is next.
      // Skip assertion if a define was passed into the test process.
      if (BtSerialPortResolver.definedPort != null) {
        expect(resolver.resolve(), isNotEmpty);
        return;
      }

      expect(resolver.resolve(), 'COM7');
    });

    test('auto-detect prefers BTHENUM / SPP UUID over name hints', () {
      final picked = BtSerialPortResolver.autoDetect(const [
        BtSerialDetectedPort(
          portName: 'COM1',
          friendlyName: 'USB Serial',
          hardwareID: 'USB\\VID_1234',
        ),
        BtSerialDetectedPort(
          portName: 'COM4',
          friendlyName: 'Standard Serial over Bluetooth link',
          hardwareID:
              'BTHENUM\\{00001101-0000-1000-8000-00805F9B34FB}_LOCALMFG&0000',
        ),
        BtSerialDetectedPort(
          portName: 'COM9',
          friendlyName: 'ELM327 Cable',
          hardwareID: 'USB\\VID_ELM',
        ),
      ]);
      expect(picked, 'COM4');
    });

    test('auto-detect falls back to ELM/OBD/Vgate names', () {
      final picked = BtSerialPortResolver.autoDetect(const [
        BtSerialDetectedPort(
          portName: 'COM2',
          friendlyName: 'Communications Port',
          hardwareID: 'ACPI\\PNP0501',
        ),
        BtSerialDetectedPort(
          portName: 'COM8',
          friendlyName: 'Vgate iCar Pro',
          hardwareID: 'USB\\VID_XXXX',
        ),
      ]);
      expect(picked, 'COM8');
    });

    test('resolve throws StateError when no candidate', () {
      final resolver = BtSerialPortResolver(
        envReader: (_) => null,
        listPorts: () => const [
          BtSerialDetectedPort(
            portName: 'COM1',
            friendlyName: 'Communications Port',
            hardwareID: 'ACPI\\PNP0501',
          ),
        ],
      );

      if (BtSerialPortResolver.definedPort != null) {
        // Cannot assert failure path when define forces a port.
        return;
      }

      expect(
        resolver.resolve,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No OBD Bluetooth COM port found'),
          ),
        ),
      );
    });

    test('normalizePortName accepts bare digits', () {
      expect(BtSerialPortResolver.normalizePortName('5'), 'COM5');
      expect(BtSerialPortResolver.normalizePortName(' com3 '), 'COM3');
    });
  });
}
