# Using rdf_dart

A comprehensive guide to performing common RDF 1.2 tasks with the `rdf_dart` library.

## Table of Contents
- [Creating RDF Terms](#creating-rdf-terms)
  - [Named Nodes (IRIs)](#named-nodes-iris)
  - [Blank Nodes](#blank-nodes)
  - [Literals](#literals)
  - [Triple Terms (RDF-star / RDF 1.2)](#triple-terms)
- [Building Statements](#building-statements)
  - [Triples](#triples)
  - [Quads](#quads)
- [Working with Graphs](#working-with-graphs)
- [Working with Datasets](#working-with-datasets)
- [Serialization and Deserialization](#serialization-and-deserialization)
  - [N-Triples](#n-triples)
  - [N-Quads](#n-quads)
  - [Turtle](#turtle)

---

## Creating RDF Terms

The `Term` class is a `sealed` hierarchy representing the four types of RDF terms defined in RDF 1.2.

### Named Nodes (IRIs)

Use `NamedNode` to represent resources identified by an IRI. IRIs must be absolute.

```dart
import 'package:rdf_dart/rdf_dart.dart';

final bob = NamedNode('https://example.org/bob');
final knows = NamedNode('https://example.org/vocab#knows');

print(bob.value); // https://example.org/bob
```

### Blank Nodes

`BlankNode` represents a resource without an explicit IRI. You can provide an identifier or let the library generate a unique one.

```dart
final b1 = BlankNode(); // Generated: b0, b1, ...
final b2 = BlankNode('my-id');

print(b2.value); // my-id
```

### Literals

Literals represent data values like strings, numbers, and dates.

#### Built-in Datatypes (XSD)

The `Xsd` class provides constants for common XML Schema datatypes.

```dart
// Explicit creation
final age = Literal('25', datatype: Xsd.integer);

// Using the fromValue factory for automatic mapping and canonicalization
final price = Literal.fromValue(19.99); // Automatically uses xsd:double
final isActive = Literal.fromValue(true); // xsd:boolean "true"
```

#### Language Tags

Literals can have language tags, following BCP 47.

```dart
final hello = Literal('Hello', language: 'en');
final bonjour = Literal('Bonjour', language: 'fr');
```

#### RDF 1.2 `dirLangString`

RDF 1.2 introduces support for text direction (left-to-right or right-to-left) alongside language tags.

```dart
final ar = Literal(
  'مرحبا',
  language: 'ar',
  baseDirection: 'rtl',
  datatype: NamedNode('http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString'),
);
```

#### Custom Datatypes

You can use any IRI as a datatype.

```dart
final myType = NamedNode('https://example.org/types/MyCustomType');
final customLiteral = Literal('raw-data', datatype: myType);
```

### Triple Terms

RDF 1.2 (and RDF-star) allows using a triple as a term within another triple (e.g., for metadata/annotations).

```dart
final statement = Triple(
  subject: bob,
  predicate: knows,
  object: NamedNode('https://example.org/alice'),
);

// The 'statement' itself is now a Term that can be used as a subject or object
final metadata = Triple(
  subject: statement,
  predicate: NamedNode('https://example.org/vocab#certainty'),
  object: Literal.fromValue(0.9),
);
```

---

## Building Statements

### Triples

A `Triple` consists of a subject, predicate, and object.

```dart
final triple = Triple(
  subject: bob,
  predicate: knows,
  object: b1,
);
```

### Quads

A `Quad` adds an optional graph name to a triple, used in Datasets.

```dart
final quad = Quad(
  subject: bob,
  predicate: knows,
  object: b1,
  graph: NamedNode('https://example.org/graphs/social'),
);
```

---

## Working with Graphs

A `Graph` is a collection of triples. `MemoryGraph` is the default in-memory implementation.

```dart
final graph = MemoryGraph();

// Adding triples
graph.add(triple);
graph.addAll([
  Triple(subject: b1, predicate: NamedNode('https://example.org/vocab#name'), object: Literal('Secret Friend')),
]);

// Pattern Matching
final matches = graph.match(subject: bob);
for (final t in matches) {
  print('Bob ${t.predicate.value} ${t.object.value}');
}

// Iterable properties
print(graph.length); // 2
print(graph.contains(triple)); // true
```

---

## Working with Datasets

A `Dataset` manages multiple graphs.

```dart
final dataset = MemoryDataset();

// Add quads
dataset.add(quad);

// Access specific graphs
final defaultGraph = dataset.defaultGraph;
final socialGraph = dataset.getGraph(NamedNode('https://example.org/graphs/social'));

// Query across the whole dataset
final allKnows = dataset.match(predicate: knows);
```

---

## Serialization and Deserialization

### N-Triples

Ideal for line-based graph serialization.

```dart
final ntString = nTriplesCodec.encode(graph);
print(ntString);

// Deserialization
final decodedTriples = nTriplesCodec.decode(ntString);
final newGraph = MemoryGraph.fromIterable(decodedTriples);
```

### N-Quads

Ideal for dataset serialization.

```dart
final nqString = nQuadsCodec.encode(dataset);

// Deserialization
final decodedQuads = nQuadsCodec.decode(nqString);
final newDataset = MemoryDataset.fromIterable(decodedQuads);
```

### Turtle

Turtle provides a more human-readable format for graphs.

```dart
// Turtle encoding (standard)
final ttlString = turtleCodec.encode(graph);

// Turtle decoding
final fromTtl = turtleCodec.decode(ttlString);
```

---

## Advanced Topics

### Isomorphism

Check if two graphs or datasets are structurally identical, even if their blank node identifiers differ.

```dart
final g1 = MemoryGraph();
final g2 = MemoryGraph();

final bNode1 = BlankNode();
final bNode2 = BlankNode();

g1.add(Triple(subject: bob, predicate: knows, object: bNode1));
g2.add(Triple(subject: bob, predicate: knows, object: bNode2));

print(isomorphic(g1, g2)); // true
```

### Basic Encoding (RDF 1.2 Interoperability)

RDF 1.2 defines a "Basic Encoding" that transforms "Full RDF" (which uses Triple Terms) into "Basic RDF" (which uses blank node reification). This is useful for interoperability with older RDF systems.

```dart
final fullGraph = MemoryGraph();
// ... add triples with triple terms ...

// Transform to Basic RDF
final basicGraph = fullGraph.basicEncode();

// The resulting graph will have replaced Triple Terms with blank nodes 
// and metadata triples using rdf:propositionForm.
```
