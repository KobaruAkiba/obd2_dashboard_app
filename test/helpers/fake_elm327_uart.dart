import 'dart:async';
import 'dart:convert';

import 'package:odb_dashboard/domain/obd/elm327/elm327_client.dart';
import 'package:odb_dashboard/domain/obd/elm327/elm327_commands.dart';

/// In-memory [Elm327Uart] for unit tests — responds to AT init and Mode $01 PIDs.
class FakeElm327Uart implements Elm327Uart {
  FakeElm327Uart({
    this.rpmA = 0x1A,
    this.rpmB = 0xF8,
    this.speed = 90,
  });

  final int rpmA;
  final int rpmB;
  final int speed;

  final _incomingController = StreamController<List<int>>.broadcast();
  final written = <String>[];

  bool failNextWrite = false;
  bool respond = true;

  @override
  Stream<List<int>> get incoming => _incomingController.stream;

  @override
  Future<void> write(List<int> data) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('fake UART write failed');
    }

    final text = utf8.decode(data).replaceAll('\r', '').trim();
    written.add(text);
    if (!respond) return;

    final reply = _replyFor(text);
    // Fragment to mimic real UART chunking.
    final bytes = utf8.encode(reply);
    if (bytes.length > 4) {
      _incomingController.add(bytes.sublist(0, 4));
      _incomingController.add(bytes.sublist(4));
    } else {
      _incomingController.add(bytes);
    }
  }

  String _replyFor(String cmd) {
    final u = cmd.toUpperCase();
    if (u == Elm327Commands.reset) {
      return 'ELM327 v1.5\r\n>';
    }
    if (u.startsWith('AT')) {
      return 'OK\r\n>';
    }
    if (u == Elm327Commands.pidRpm) {
      return '41 0C ${_hex(rpmA)} ${_hex(rpmB)}\r\n>';
    }
    if (u == Elm327Commands.pidSpeed) {
      return '41 0D ${_hex(speed)}\r\n>';
    }
    if (u == Elm327Commands.pidCoolant) {
      return '41 05 80\r\n>';
    }
    if (u == Elm327Commands.pidIntake) {
      return '41 0F 46\r\n>';
    }
    if (u == Elm327Commands.pidThrottle) {
      return '41 11 80\r\n>';
    }
    if (u == Elm327Commands.pidFuelLevel) {
      return '41 2F 7F\r\n>';
    }
    if (u == Elm327Commands.pidModuleVoltage) {
      return '41 42 33 90\r\n>';
    }
    return 'NO DATA\r\n>';
  }

  static String _hex(int b) => b.toRadixString(16).padLeft(2, '0').toUpperCase();

  void dispose() {
    _incomingController.close();
  }
}
