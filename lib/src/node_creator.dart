import 'package:uuid/uuid.dart';

class NodeCreator {
  final String id;
  final String meta;
  final String fileName;

  NodeCreator({
    required this.id,
    required this.meta,
    required this.fileName,
  });

  factory NodeCreator.createNode(String title, {List<String> tags = const []}) {
    final id = Uuid().v1();
    final date = DateTime.now()
        .toString()
        .split('.')[0]
        .replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    final fileName = '$date-${_titleSlug(title)}.org';
    final meta = _metaTemplate(id, title, tags);
    return NodeCreator(
      id: id,
      meta: meta,
      fileName: fileName,
    );
  }
}

String _titleSlug(String title) {
  return title
      .replaceAll(RegExp(r'[^0-9a-zA-Z]{1,}'), ' ')
      .trim()
      .replaceAll(' ', '_')
      .toLowerCase();
}

String _metaTemplate(String id, String title, List<String> tags) {
  return '''
:PROPERTIES:
:ID:       $id
:END:${tags.isNotEmpty ? '\n#+file_tags: ${tags.join(' ')}' : ''}
#+title: $title
''';
}
