# Feature Plan: Organization Resource (schema:Organization)

## 1. Background & Motivation
The application needs a new resource type representing an organization. It will support various specific subclasses of `schema:Organization` (e.g., `NGO`, `GovernmentOrganization`, `LocalBusiness`, `OnlineBusiness`). Users must be able to specify the organization type during creation via a dropdown menu. The resource will support `name`, `legalName`, `description`, and `url` fields, with `name` being mandatory.

## 2. Scope & Impact
This feature requires changes across the entire architectural stack:
*   **API Model (`lib/api/models/organization.dart`)**: Define the `Organization` class and `OrganizationType` enum. Implement dataset parsing/serialization. Note: The Schema `name` field will map to Dart's `displayName` to comply with AIP-122 (which reserves the `name` field for the resource identifier).
*   **Vocabulary (`lib/api/models/vocab.dart`)**: Register the new classes and properties (`legalName`, `url`).
*   **API Requests (`lib/api/models/api_requests.dart`)**: Add DTOs for Organization CRUD requests.
*   **Backend Server (`lib/server/controllers/organization_controller.dart`)**: Implement the CRUD logic directly interacting with the RDF triplestore.
*   **Routing (`lib/server/router/server_router.dart`)**: Wire up `/organizations` endpoints.
*   **Domain & Data**: Implement `OrganizationApiService`, `OrganizationRepository`, `OrganizationRepositoryImpl`, and the standard `Get`, `Save`, `Delete` UseCases.
*   **UI (`lib/ui/views/organization_*.dart`)**: Create List and Form screens. The Form screen will include a dropdown for the `OrganizationType` enum and text fields for the properties.
*   **Navigation (`lib/ui/router/app_router.dart`, `app_shell.dart`)**: Add the "Organizations" tab to the NavigationRail.
*   **Tests**: Unit tests for the model, Fake repository, server API tests, and widget tests.

## 3. Proposed Solution
### RDF Data Model
We will persist the specific selected type as the primary `rdf:type` alongside the fields.

```turtle
@prefix schema: <https://schema.org/> .
@prefix api: <https://example.com/api/> .

api:organizations/O1 a schema:LocalBusiness ;
    schema:name "Acme Corp" ;
    schema:legalName "Acme Corporation LLC" ;
    schema:description "A great local business." ;
    schema:url "https://acme.com" .
```

### Dart Model Mapping
The `OrganizationType` enum will handle parsing the correct `NamedNode` for `rdf:type`.

## 4. Implementation Steps

### Phase 1: Vocabulary & Model
1.  Update `Vocab` with: `organizationClass`, `ngoClass`, `governmentOrganizationClass`, `localBusinessClass`, `onlineBusinessClass`, `legalName`, `url`.
2.  Create `OrganizationType` enum mapping to these Vocab URIs.
3.  Create `Organization` model and JSON serialization. Throw `ArgumentError` if `displayName` (mapped to `schema:name`) is empty.
4.  Add API Requests DTOs for Organization.

### Phase 2: Server & Router
1.  Create `OrganizationController` with standard CRUD operations.
2.  Register routes in `ServerRouter`.

### Phase 3: Domain & Data
1.  Create `OrganizationApiService` and `OrganizationRepository` (with `Impl`).
2.  Create `GetOrganizationsUseCase`, `SaveOrganizationUseCase`, and `DeleteOrganizationUseCase`.

### Phase 4: UI & Navigation
1.  Create `OrganizationListViewModel` and `OrganizationFormViewModel`.
2.  Build `OrganizationListScreen` and `OrganizationFormScreen`.
3.  Wire everything up in `AppShell` (new tab), `app_router.dart`, `app.dart`, and `main.dart`.

### Phase 5: Testing
1.  Create `FakeOrganizationRepository`.
2.  Write unit tests for `Organization` model to ensure validation and correct `rdf:type` serialization.
3.  Write `organization_api_test.dart` for server endpoints.
4.  Verify everything runs correctly via `flutter test`.