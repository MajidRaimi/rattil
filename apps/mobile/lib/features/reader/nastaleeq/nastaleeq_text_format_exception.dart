class NastaleeqTextFormatException implements Exception {
  final String asset;
  final String reason;

  const NastaleeqTextFormatException(this.asset, this.reason);

  @override
  String toString() => 'NastaleeqTextFormatException($asset): $reason';
}
