import 'package:org_roam/src/org_roam_network.dart';

import 'link.dart';

class OrgRoamNetworkMeta {
  final Set<String> total;
  final Set<String> start;
  final Set<String> end;
  final Set<String> leaves;
  final Set<String> root;
  final Set<String> parent;
  final Set<String> orphan;
  final Map<String, int> levels;
  final Map<String, int> weights;

  const OrgRoamNetworkMeta({
    required this.total,
    required this.start,
    required this.end,
    required this.leaves,
    required this.root,
    required this.parent,
    required this.orphan,
    required this.weights,
    required this.levels,
  });

  factory OrgRoamNetworkMeta.fromNetwork(OrgRoamNetwork network) {
    final total = network.nodes.keys.toSet();
    final start = network.links.map((e) => e.start).toSet();
    final end = network.links.map((e) => e.end).toSet();
    final group = start.union(end);
    final root = start.difference(end);
    final orphan = total.difference(group);
    final leaves = end.difference(start).union(orphan);
    final parent = root.difference(orphan);
    return OrgRoamNetworkMeta(
      total: total,
      start: start,
      end: end,
      leaves: leaves,
      root: root,
      parent: parent,
      orphan: orphan,
      levels: _calculateLevels(network, leaves),
      weights: _calculateWeights(network, leaves),
    );
  }
}

Map<String, int> _calculateLevels(OrgRoamNetwork network, Set<String> leaves) {
  final links = network.links.toSet();
  final weights = <String, int>{};
  weights.addEntries(leaves.map((e) => MapEntry(e, 1)));
  var level = 1;
  while (leaves.isNotEmpty) {
    level++;
    leaves = _levelsFromLinks(weights, links, leaves, level);
  }
  return weights;
}

Set<String> _levelsFromLinks(
    Map<String, int> map, Set<Link> links, Set<String> leaves, int level) {
  for (final leaf in leaves) {
    final removableLinks = <Link>[];
    for (final link in links) {
      if (link.end == leaf) {
        if (map[link.start] == null) {
          map[link.start] = level;
        }
        removableLinks.add(link);
      }
    }
    links.removeAll(removableLinks);
  }
  return links
      .map((e) => e.end)
      .toSet()
      .difference((links.map((e) => e.start).toSet()));
}

Map<String, int> _calculateWeights(OrgRoamNetwork network, Set<String> leaves) {
  final links = network.links.toSet();
  final weights = <String, int>{};
  weights.addEntries(network.nodes.keys.map((e) => MapEntry(e, 1)));
  while (leaves.isNotEmpty) {
    leaves = _weightsFromLinks(weights, links, leaves);
  }
  return weights;
}

Set<String> _weightsFromLinks(
    Map<String, int> map, Set<Link> links, Set<String> leaves) {
  for (final leaf in leaves) {
    final removableLinks = <Link>[];
    for (final link in links) {
      if (link.end == leaf) {
        map[link.start] = map[link.start]! + map[leaf]!;
        removableLinks.add(link);
      }
    }
    links.removeAll(removableLinks);
  }
  return links
      .map((e) => e.end)
      .toSet()
      .difference((links.map((e) => e.start).toSet()));
}
