/// One classical CAN frame (11-bit ID, up to 8 data bytes).
class CanFrame {
  const CanFrame({
    required this.id,
    required this.data,
    this.timestampMicros,
    this.isExtended = false,
    this.isRtr = false,
  });

  final int id;
  final List<int> data;
  final int? timestampMicros;
  final bool isExtended;
  final bool isRtr;

  int get dlc => data.length.clamp(0, 8);

  CanFrame copyWith({
    int? id,
    List<int>? data,
    int? timestampMicros,
    bool? isExtended,
    bool? isRtr,
  }) {
    return CanFrame(
      id: id ?? this.id,
      data: data ?? this.data,
      timestampMicros: timestampMicros ?? this.timestampMicros,
      isExtended: isExtended ?? this.isExtended,
      isRtr: isRtr ?? this.isRtr,
    );
  }

  @override
  String toString() =>
      'CanFrame(id=0x${id.toRadixString(16)}, dlc=$dlc, data=$data)';
}
