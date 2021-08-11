import 'hash_utils.dart';

class Link {
  final String start;
  final String end;

  const Link(this.start, this.end);

  @override
  bool operator ==(Object other) {
    if (other is Link) return other.start == start && other.end == end;
    return false;
  }

  @override
  int get hashCode => hashValues(start, end);

  Map<String, dynamic> toJson() => {
        'source': start,
        'target': end,
        'value': 2,
      };
}
