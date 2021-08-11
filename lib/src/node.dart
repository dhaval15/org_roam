import 'hash_utils.dart';

class Node implements Comparable<Node> {
  final String title;
  final String id;
  final String file;
  final int level;
  final List<String> parentChain;

  String get label => [...parentChain, title].join('/');

  Node({
    required this.level,
    required this.file,
    required this.title,
    required this.id,
    required this.parentChain,
  });

  @override
  int compareTo(Node other) {
    return id.compareTo(other.id);
  }

  @override
  bool operator ==(Object other) {
    if (other is Node) return other.id == id;
    return false;
  }

  @override
  int get hashCode => hashValues(title, id, file, level, parentChain);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'file': file,
        'level': level,
        'parentChain': parentChain,
      };

  static final none = Node(
    file: 'NA',
    title: 'NA',
    level: -1,
    id: 'NA',
    parentChain: [],
  );
}

class NodeProperties {
  final String category;
  final String id;
  final String blocked;
  final String? item;
  final String file;
  final String priority;

  const NodeProperties({
    required this.category,
    required this.id,
    this.blocked = '',
    this.item,
    required this.file,
    this.priority = 'B',
  });

  Map<String, dynamic> toJson() => {
        'CATEGORY': category,
        'ID': id,
        'BLOCKED': blocked,
        'ITEM': item,
        'PRIORITY': priority,
        'FILE': file,
      };
}
