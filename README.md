# Isolate Core Architecture

An advanced, fully decoupled Flutter application demonstrating how to build a highly scalable, robust architecture utilizing Domain-Driven Design (Clean Architecture), Google AIP standards, Linked Data Patterns, and simulated IPC (Inter-Process Communication) via Dart Isolates.

## Overview

This project serves as a blueprint for applications that require strict separation between client-side business logic, shared API contracts, and backend data processing. The server runs entirely within a background Dart Isolate, communicating with the main Flutter UI thread via simulated HTTP transport layers.

### Key Features
- **Clean Architecture Client:** Strict separation of UI (Views, ViewModels, & Declarative Routing), Domain (UseCases & Repository Interfaces), and Data (Repository Implementations & API Services).
- **Standalone API Server:** A modular backend running in an Isolate featuring standard HTTP-like Routers (utilizing Dart 3 pattern matching), Controllers, and abstract Storage Interfaces.
- **Google AIP Compliance:** 
  - **AIP-122:** Formal `ResourceName` encapsulation (`things/uuid`, `tasks/uuid`).
  - **AIP-127:** HTTP Transcoding, mapping structured Request/Response DTOs onto raw HTTP verbs, paths, and query parameters. Includes support for sub-collections (e.g., `/taskLists/{id}/tasks`).
  - **AIP-134:** Standard Update methods using `PATCH` operations and partial `updateMask` fields. Note: `updateMask` is intentionally omitted for partial updates involving Blank Nodes to fully replace the graph and avoid data loss.
- **Linked Data Patterns & Schema.org:**
  - Uses well-known ontologies (`schema:ItemList`, `schema:Action`) instead of inventing custom vocabularies.
  - Employs **Patterned URIs** and **Decoupled Graphs** to model complex many-to-many relationships (e.g., GTD-style Tasks belonging to multiple TaskLists).
- **Declarative Navigation:** Uses `go_router` for deep-linkable, organized client-side navigation.
- **Isolate Transport Layer:** A custom transport mechanism (`TransportRequest` / `TransportResponse`) that simulates a real network boundary without requiring an actual HTTP server.
- **RDF Data Layer:** A semantic data layer using `rdf_dart` that persists data in perfectly encapsulated N-Quads Datasets. Includes a `/debug/dump` endpoint for easy inspection.
- **Comprehensive Testing Suite:** Fully unit-tested and widget-tested utilizing Fakes (in-memory data) rather than brittle mocks.

## Project Structure

The codebase is split into three primary boundaries:

```
lib/
├── api/          # Shared Contracts (DTOs, Resource Models, Schema.org Vocab)
├── ui/           # Flutter UI components, ViewModels, and go_router configuration
├── domain/       # Core Client Business Logic (UseCases, Interfaces)
├── data/         # Client Data Fetching (Repositories, API Services)
├── transport/    # IPC layer mapping Isolate Messages to HTTP semantics
└── server/       # Standalone Backend (Router, Controllers, Storage)
```

## Architecture Details

### 1. The API Layer
The `lib/api/` package acts as the single source of truth for the API contract. Both the client and server depend on this package to serialize and deserialize data, ensuring strong typing across the "network" boundary. It heavily leverages `schema.org` terms.

### 2. The Client
The Flutter client knows absolutely nothing about the backend implementation. 
- **ViewModels** orchestrate state.
- **UseCases** handle discrete business actions (e.g., `GetTaskListsUseCase`, `SaveTaskUseCase`).
- **Repositories** interface with API Services (`TaskApiService`, `TaskListApiService`) which seamlessly transcode formal DTOs into `TransportRequests`.
- **Router** (`app_router.dart`) manages navigation using `go_router`.

### 3. The Server
Running in a spawned background isolate, `ApiServer` receives raw `TransportRequest` objects. 
- The **ServerRouter** parses paths using advanced Dart 3 switch expressions and record matching.
- The **Controllers** (`ThingController`, `TaskController`, `TaskListController`) extract Datasets and enforce business rules.
- The **Storage** (abstracted) persists the data. We currently use `RdfResourceStorage` backed by an in-memory `MemoryFileSystem`, serializing application state to N-Quads.

## Testing

The project adheres to strict testing guidelines outlined in the `flutter-testing-apps` specifications.

### Running Tests
```bash
flutter test
```

### Testing Strategy
- **Fakes Over Mocks:** The client UI and Domain layers are tested against Fake repositories (e.g., `FakeThingRepository`), allowing instant, highly deterministic unit and widget tests.
- **Headless Server Tests:** The `ApiServer` is integration tested by injecting a `MemoryFileSystem`, allowing us to fire raw HTTP-like requests directly at the backend logic and verify RDF/N-Quads responses, including complex sub-collection queries.

## Future Extensibility

Because of the architectural boundaries established in this project, migrating the `IsolateServer` to a real HTTP framework (e.g. Dart Frog, Shelf) requires zero changes to the `lib/server/controllers` or `lib/api` packages. Simply swap the Isolate Transport layer for a real HTTP server adapter, and deploy!
