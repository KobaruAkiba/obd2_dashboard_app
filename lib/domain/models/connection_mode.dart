/// High-level connection mode shown in the UI.
///
/// Pure domain enum — no Flutter imports. UI labels/icons live in
/// `presentation/connection/connection_mode_ui.dart`.
enum ConnectionMode {
  disconnected,
  connecting,
  mock,
  bluetooth,
  canBus,
  error,
}
