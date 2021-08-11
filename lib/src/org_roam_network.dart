import 'node.dart';
import 'link.dart';

class OrgRoamNetwork {
  final Map<String, Node> nodes;
  final List<Link> links;

  const OrgRoamNetwork({
    required this.nodes,
    required this.links,
  });

  void add(OrgRoamNetwork network) {
    nodes.addAll(network.nodes);
    links.addAll(network.links);
  }

  Node find(String id) => nodes[id]!;

  List<Node> incoming(String id) {
    return links
        .where((element) => element.end == id)
        .map((element) {
          return find(element.start);
        })
        .toSet()
        .toList();
  }

  List<Node> outgoing(String id) {
    return links
        .where((element) => element.start == id)
        .map((element) {
          return find(element.end);
        })
        .toSet()
        .toList();
  }

  OrgRoamNetwork focus(String id) {
    final subLinks = <Link>[];
    final subNodeIds = <String>{id};
    for (final link in links) {
      if (link.start == id || link.end == id) {
        subLinks.add(link);
        if (link.start != id) subNodeIds.add(link.start);
        if (link.end != id) subNodeIds.add(link.end);
      }
    }
    final subNodes =
        Map.fromEntries(subNodeIds.map((e) => MapEntry(e, find(e))));
    return OrgRoamNetwork(nodes: subNodes, links: subLinks);
  }

  List<Link> highlightLinks(String id) {
    return links
        .where((element) => element.start == id && element.end == id)
        .toList();
  }
}
