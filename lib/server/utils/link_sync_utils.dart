import 'package:rdf_dart/rdf_dart.dart';
import '../data/resource_storage.dart';

class LinkSyncUtils {
  static Future<void> syncBidirectionalLinks({
    required ResourceStorage storage,
    required NamedNode sourceIri,
    required Dataset oldDataset,
    required Dataset newDataset,
    required NamedNode forwardPredicate,
    required NamedNode reversePredicate,
  }) async {
    final oldTargets = oldDataset
        .match(subject: sourceIri, predicate: forwardPredicate)
        .map((q) => q.object)
        .whereType<NamedNode>()
        .toSet();
    
    final newTargets = newDataset
        .match(subject: sourceIri, predicate: forwardPredicate)
        .map((q) => q.object)
        .whereType<NamedNode>()
        .toSet();

    final addedTargets = newTargets.difference(oldTargets);
    final removedTargets = oldTargets.difference(newTargets);

    for (final targetIri in addedTargets) {
      final targetDataset = await storage.getResource(targetIri);
      if (targetDataset != null) {
        targetDataset.add(
          Quad(
            subject: targetIri,
            predicate: reversePredicate,
            object: sourceIri,
            graph: targetIri, // Resource graph
          ),
        );
        await storage.saveResource(targetIri, targetDataset);
      }
    }

    for (final targetIri in removedTargets) {
      final targetDataset = await storage.getResource(targetIri);
      if (targetDataset != null) {
        final toRemove = targetDataset
            .match(
              subject: targetIri,
              predicate: reversePredicate,
              object: sourceIri,
              graph: targetIri,
            )
            .toList();
        for (final q in toRemove) {
          targetDataset.remove(q);
        }
        await storage.saveResource(targetIri, targetDataset);
      }
    }
  }
}
