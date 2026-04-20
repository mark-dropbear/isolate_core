# Isolate Core Architecture

An advanced, fully decoupled Flutter application demonstrating how to build a highly scalable, robust architecture utilizing Domain-Driven Design (Clean Architecture), Google AIP standards, and simulated IPC (Inter-Process Communication) via Dart Isolates.

## Overview

This project serves as a blueprint for applications that require strict separation between client-side business logic, shared API contracts, and backend data processing. The server runs entirely within a background Dart Isolate, communicating with the main Flutter UI thread via simulated HTTP transport layers.

### Key Features
- **Clean Architecture Client:** Strict separation of UI (Views & ViewModels), Domain (Generic UseCases & Repository Interfaces), and Data (Generic Repositories & API Services).
- **Dependency Injection:** Centralized `get_it` container for clean dependency resolution, preventing manual prop-drilling in the UI tree.
- **Standalone API Server:** A modular backend running in an Isolate featuring standard HTTP-like Routers, highly generic Controllers (`StandardResourceController`), and abstract Storage Interfaces.
- **Google AIP Compliance:** 
  - **AIP-122:** Formal `ResourceName` encapsulation using dense, human-readable **Crockford Base32** identifiers with Modulo-37 checksum validation.
  - **AIP-127:** HTTP Transcoding, mapping structured Request/Response DTOs onto raw HTTP verbs, paths, and query parameters.
  - **AIP-131:** Standard generic methods (Get, List, Create, Update, Delete) mapped seamlessly across both frontend and backend generic classes.
  - **AIP-134:** Standard Update methods using `PATCH` operations and partial `updateMask` fields, mapped directly to precise RDF triple insertions/deletions.
- **Isolate Transport Layer:** A custom transport mechanism (`TransportRequest` / `TransportResponse`) that simulates a real network boundary without requiring an actual HTTP server.
- **RDF Data Layer:** A semantic data layer using `rdf_dart` that persists data in perfectly encapsulated N-Quads Datasets.

## Project Structure

The codebase is split into three primary boundaries:

```
lib/
├── api/          # Shared Contracts (DTOs, Resource Models, Vocabularies)
├── core/         # Core Utilities (Dependency Injection setup via get_it)
├── ui/           # Flutter UI components, Widgets, and ViewModels
├── domain/       # Core Client Business Logic (Generic UseCases, Interfaces)
├── data/         # Client Data Fetching (Generic Repositories, API Services)
├── transport/    # IPC layer mapping Isolate Messages to HTTP semantics
└── server/       # Standalone Backend (Router, Generic Controllers, Storage)
```

## Architecture Details

### 1. The API Layer
The `lib/api/` package acts as the single source of truth for the API contract. Both the client and server depend on this package to serialize and deserialize data via highly semantic RDF graphs, ensuring strong typing across the "network" boundary.

### 2. The Client
The Flutter client knows absolutely nothing about the backend implementation. 
- **Dependency Injection** (`get_it`) resolves all viewmodels and usecases on demand.
- **ViewModels** orchestrate state without worrying about how data is fetched.
- **Generic UseCases** handle discrete business actions (`ListResourcesUseCase<T>`, `SaveResourceUseCase<T>`).
- **Generic Repositories** interface with the `StandardResourceApiService<T>` which seamlessly transcodes generic operations into `TransportRequests`.

### 3. The Server
Running in a spawned background isolate, `ApiServer` receives raw `TransportRequest` objects. 
- The **ServerRouter** parses paths and delegates to instances of `StandardResourceController`.
- The **StandardResourceController** is a highly generic controller that enforces business rules and extracts semantic datasets based on provided `Vocab` mappers.
- The **ResourceStorage** (abstracted) persists the data. We currently use `RdfResourceStorage` backed by an in-memory `MemoryFileSystem`, serializing application state to N-Quads.

## Testing

The project adheres to strict testing guidelines outlined in the `flutter-testing-apps` specifications.

### Running Tests
```bash
flutter test
```

### Testing Strategy
- **Fakes Over Mocks:** The client UI and Domain layers are tested against a `FakeThingRepository`, allowing instant, highly deterministic unit and widget tests.
- **Headless Server Tests:** The `ApiServer` is integration tested by injecting a `MemoryFileSystem`, allowing us to fire raw HTTP-like requests directly at the backend logic and verify JSON responses.

## Future Extensibility

Because of the architectural boundaries established in this project, migrating the `IsolateServer` to a real HTTP framework (e.g. Dart Frog, Shelf) requires zero changes to the `lib/server/controllers` or `lib/api` packages. Simply swap the Isolate Transport layer for a real HTTP server adapter, and deploy!
