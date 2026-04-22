# Isolate Core: Project Overview & Context

`isolate_core` is a reference implementation of a highly decoupled Flutter application. It features a standalone backend running within a Dart Isolate, communicating via a simulated HTTP transport layer. The project strictly adheres to Domain-Driven Design (Clean Architecture), Google AIP standards, and utilizes RDF (Resource Description Framework) for its semantic data layer.

## Core Architecture & Boundaries

The codebase is organized into discrete architectural boundaries to ensure a strict separation of concerns:

- **`lib/api/`**: **Shared Contracts.** Contains the single source of truth for DTOs (Data Transfer Objects), Resource Models, and Resource Names. This layer is shared between the Client and the Server. Uses Schema.org vocabulary where applicable.
- **`lib/server/`**: **Background Backend.** A modular server implementation running in a background Isolate. It includes Routers (utilizing Dart 3 pattern matching), Controllers, and abstract Storage interfaces.
- **`lib/transport/`**: **IPC Layer.** Maps Isolate messages to HTTP semantics (`TransportRequest` / `TransportResponse`), simulating a network boundary.
- **`lib/domain/`**: **Client Business Logic.** Contains UseCases and Repository interfaces. It knows nothing about the backend implementation or the transport layer.
- **`lib/data/`**: **Client Implementation.** Implements repositories by interacting with API services that transcode domain requests into `TransportRequest` objects.
- **`lib/ui/`**: **Presentation Layer.** Flutter widgets, ViewModels (MVVM) orchestrating state, and declarative routing via `go_router`.

## Key Technologies & Standards

- **Dart Isolates**: Used to run the `ApiServer` off the main UI thread.
- **rdf_dart**: A custom semantic data library for working with RDF 1.2, N-Quads, and Triple Terms (RDF-star).
- **Google AIP Compliance**:
    - **AIP-122 (Resource Names)**: Uses `ResourceName` with Crockford's Base32 encoding and a Modulo-37 checksum for high reliability and human readability.
    - **AIP-127 (HTTP Transcoding)**: Maps structured DTOs to standard HTTP verbs, paths, and query parameters.
    - **AIP-134 (Standard Update)**: Implements `PATCH` operations with an `updateMask`, mapping directly to RDF triple mutations.
- **Linked Data Patterns & Schema.org**: 
    - Uses well-known ontologies (like `schema:ItemList`, `schema:Action`) instead of inventing custom vocabularies.
    - Employs **Patterned URIs** and **Decoupled Graphs** to model many-to-many relationships (e.g., GTD-style Tasks belonging to multiple TaskLists).
    - Omits `updateMask` for partial updates involving Blank Nodes (like `schema:ListItem`) to fully replace the graph and avoid data loss.
- **Declarative Routing**: Uses `go_router` for deep-linkable and organized client-side navigation.
- **File System Abstraction**: Uses `package:file` to allow injecting a `MemoryFileSystem` for headless server testing and fast persistence.

## Development & Testing Conventions

- **Fakes over Mocks**: Prefer using `Fake` implementations (e.g., `FakeThingRepository`) for UI and Domain testing. This ensures tests are deterministic, maintainable, and reflect real behavior better than brittle mocks.
- **Headless Server Testing**: The `ApiServer` is tested by firing raw `TransportRequest` objects at it and verifying the resulting `TransportResponse`, often using an in-memory storage backend.
- **Semantic Data**: Data is stored as N-Quads. Refer to `RDF.md` for detailed instructions on using the `rdf_dart` library. A `/debug/dump` endpoint allows fetching the entire dataset to clipboard for easy inspection.
- **Identifier Integrity**: Identifiers are generated as Crockford Base32 strings with a checksum character. See `resource_identifiers_guide.md` for the full rationale.

## Key Commands

| Task | Command |
| :--- | :--- |
| **Run App** | `flutter run` |
| **Run Tests** | `flutter test` |
| **Static Analysis** | `flutter analyze` |
| **Format Code** | `dart format .` |
| **Clean Project** | `flutter clean` |

## Important Documentation Files

- **`README.md`**: Architectural high-level overview.
- **`RDF.md`**: Guide for the `rdf_dart` library and semantic data patterns.
- **`resource_identifiers_guide.md`**: Deep dive into the AIP-122 identifier implementation.
- **`aip/`**: Contains documentation for specific Google AIP standards implemented in this project.
