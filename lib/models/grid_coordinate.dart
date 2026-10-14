class GridCoordinate {
  final int row;
  final int col;

  const GridCoordinate(this.row, this.col);

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory GridCoordinate.fromJson(Map<String, dynamic> json) {
    return GridCoordinate(
      json['row'] as int,
      json['col'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridCoordinate &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}
