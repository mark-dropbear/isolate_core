import 'package:rdf_dart/rdf_dart.dart';

class RdfUtils {
  /// Rewrites the subject and graph name of all quads in a dataset to a new target IRI.
  static Dataset rewriteResourceIri(
    Dataset dataset,
    Term oldIri,
    NamedNode targetIri,
  ) {
    final rewrittenDataset = MemoryDataset();
    for (final quad in dataset) {
      final newSubject = quad.subject == oldIri ? targetIri : quad.subject;
      final newObject = quad.object == oldIri ? targetIri : quad.object;

      rewrittenDataset.add(
        Quad(
          subject: newSubject,
          predicate: quad.predicate,
          object: newObject,
          graph: targetIri,
        ),
      );
    }
    return rewrittenDataset;
  }
}
