# Isolate Core Architecture

An advanced, fully decoupled Flutter application demonstrating how to build a highly scalable, robust architecture utilizing Domain-Driven Design (Clean Architecture), Google AIP standards, and simulated IPC (Inter-Process Communication) via Dart Isolates.

## Overview

This project serves as a blueprint for applications that require strict separation between client-side business logic, shared API contracts, and backend data processing. The server runs entirely within a background Dart Isolate, communicating with the main Flutter UI thread via simulated HTTP transport layers.

### Key Features
- **Clean Architecture Client:** Strict separation of UI (Views & ViewModels), Domain (UseCases & Repository Interfaces), and Data (Repository Implementations & API Services).
- **Standalone API Server:** A modular backend running in an Isolate featuring standard HTTP-like Routers, Controllers, and abstract Storage Interfaces.
- **Google AIP Compliance:** 
  - **AIP-122:** Formal `ResourceName` encapsulation (`things/uuid`).
  - **AIP-127:** HTTP Transcoding, mapping structured Request/Response DTOs onto raw HTTP verbs, paths, and query parameters.
  - **AIP-134:** Standard Update methods using `PATCH` operations and partial `updateMask` fields, mapped directly to precise RDF triple insertions/deletions.
- **Isolate Transport Layer:** A custom transport mechanism (`TransportRequest` / `TransportResponse`) that simulates a real network boundary without requiring an actual HTTP server.
- **RDF Data Layer:** A semantic data layer using `rdf_dart` that persists data in perfectly encapsulated N-Quads Datasets.
- **Comprehensive Testing Suite:** Fully unit-tested and widget-tested utilizing Fakes (in-memory data) rather than brittle mocks.

## Project Structure

The codebase is split into three primary boundaries:

```
lib/
├── api/          # Shared Contracts (DTOs, Resource Models) between Client and Server
├── ui/           # Flutter UI components, Widgets, and ViewModels
├── domain/       # Core Client Business Logic (UseCases, Interfaces)
├── data/         # Client Data Fetching (Repositories, API Services)
├── transport/    # IPC layer mapping Isolate Messages to HTTP semantics
└── server/       # Standalone Backend (Router, Controllers, Storage)
```

## Architecture Details

### 1. The API Layer
The `lib/api/` package acts as the single source of truth for the API contract. Both the client and server depend on this package to serialize and deserialize data, ensuring strong typing across the "network" boundary.

### 2. The Client
The Flutter client knows absolutely nothing about the backend implementation. 
- **ViewModels** orchestrate state.
- **UseCases** handle discrete business actions (`GetThingsUseCase`, `SaveThingUseCase`).
- **Repositories** interface with the `ThingApiService` which seamlessly transcodes formal DTOs into `TransportRequests`.

### 3. The Server
Running in a spawned background isolate, `ApiServer` receives raw `TransportRequest` objects. 
- The **ServerRouter** parses paths.
- The **ThingController** extracts Datasets and enforces business rules.
- The **ThingStorage** (abstracted) persists the data. We currently use `RdfThingStorage` backed by an in-memory `MemoryFileSystem`, serializing application state to N-Quads.

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
