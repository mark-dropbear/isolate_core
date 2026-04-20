import 'package:rdf_dart/rdf_dart.dart';

class RdfUtils {
  /// Rewrites the subject and graph name of all quads in a dataset to a new target IRI.
  static Dataset rewriteResourceIri(Dataset dataset, NamedNode targetIri) {
    final rewrittenDataset = MemoryDataset();
    for (final quad in dataset) {
      rewrittenDataset.add(Quad(
        subject: targetIri,
        predicate: quad.predicate,
        object: quad.object,
        graph: targetIri,
      ));
    }
    return rewrittenDataset;
  }
}
