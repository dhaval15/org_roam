import 'dart:io' hide Link;

import 'package:org_mode/org_mode.dart';

import 'link.dart';
import 'node.dart';
import 'org_roam_network.dart';

class OrgRoamParser {
  final _chain = <String>[];

  OrgRoamNetwork parse(List<String> paths) {
    final root = OrgRoamNetwork(nodes: {}, links: []);
    for (final path in paths) {
      final file = File(path);
      final neuron = _parseNeuronFromFile(file);
      root.add(neuron);
    }
    return root;
  }

  OrgRoamNetwork _parseNeuronFromFile(File file) {
    final doc = _readDoc(file);
    final parent = OrgRoamNetwork(nodes: {}, links: []);
    final id = _parseNodeIdFromContent(doc.content);
    if (id == null) return parent;
    final title = _parseNodeTitleFromContent(doc.content) ?? file.parsedLabel;
    final node = Node(
      file: file.path,
      title: title,
      parentChain: [],
      id: id,
      level: 0,
    );
    _chain.add(id);
    parent.nodes[id] = node;
    parent.links.addAll(
        _parseLinksFromContent(doc.content).map((e) => Link(_chain.last, e)));
    for (final section in doc.sections) {
      final neuron = _parseNeuronFromSection([title], section, file.path, 1);
      parent.add(neuron);
      parent.links
          .addAll(_linksForHeadlineNodes(_chain.last, neuron.nodes.values));
    }
    _chain.removeLast();
    return parent;
  }

  OrgRoamNetwork _parseNeuronFromSection(
      List<String> parentChain, OrgSection section, String path, int level) {
    final parent = OrgRoamNetwork(nodes: {}, links: []);
    final id = _parseNodeIdFromContent(section.content);
    final title = section.headline.rawTitle!;
    if (id != null) {
      final node = Node(
        file: path,
        title: title,
        parentChain: parentChain,
        id: id,
        level: level,
      );
      parent.nodes[id] = node;
      _chain.add(id);
    }
    parent.links.addAll(_parseLinksFromContent(section.content)
        .map((e) => Link(_chain.last, e)));
    for (final section in section.sections) {
      final neuron = _parseNeuronFromSection(
          [...parentChain, title], section, path, level + 1);
      parent.add(neuron);
      parent.links
          .addAll(_linksForHeadlineNodes(_chain.last, neuron.nodes.values));
    }
    if (id != null) _chain.removeLast();
    return parent;
  }

  List<Link> _linksForHeadlineNodes(String parentId, Iterable<Node> children) {
    final links = <Link>[];
    for (final node in children) {
      links.add(Link(parentId, node.id));
    }
    return links;
  }

  String? _parseNodeIdFromContent(OrgContent? content) {
    if (content == null) return null;
    String? id;
    content.visit((e) {
      if (e is OrgProperty) {
        id = e.value.trim();
        return false;
      }
      return true;
    });
    return id;
  }

  String? _parseNodeTitleFromContent(OrgContent? content) {
    if (content == null) return null;
    String? title;
    content.visit((e) {
      if (e is OrgMeta && e.keyword == '#+title:') {
        title = e.trailing.trim();
        return false;
      }
      return true;
    });
    return title;
  }

  List<String> _parseLinksFromContent(OrgContent? content) {
    if (content == null) return [];
    final links = <String>[];
    content.visit((e) {
      if (e is OrgLink) {
        links.add(e.location.split('id:')[1]);
      } else if (e is OrgList) {
        for (final item in e.items) {
          links.addAll(_parseLinksFromContent(item.body));
        }
      }
      return true;
    });
    return links;
  }

  OrgDocument _readDoc(File file) => OrgDocument.parse(file.readAsStringSync());
}

extension on File {
  String get parsedLabel {
    final filename = path.split('/').last.split('.org')[0];
    final splits = filename.split(RegExp(r'\d{14}-'))..remove(0);
    return splits.join();
  }
}
