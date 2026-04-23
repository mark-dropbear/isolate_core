# Feature Plan: Person Resource (schema:Person)

## 1. Background & Motivation
The application needs a new resource type representing a person, mapped to the `schema.org/Person` ontology. The fields are `givenName`, `familyName`, and `jobTitle`. While each field is technically optional, the business logic dictates that a Person must have at least one of these fields populated to be valid.

## 2. Scope & Impact
This is a full-stack vertical slice extending the Isolate Core architecture:
*   **API Model**: `Person` class, `Vocab` entries, and Request/Response DTOs.
*   **Backend Server**: `PersonController` for Isolate Server routing and dataset manipulation.
*   **Client Domain/Data**: `PersonRepository`, `PersonApiService`, and relevant UseCases.
*   **UI (Presentation)**: `PersonListScreen`, `PersonFormScreen`, ViewModels, and navigation updates via `go_router`.
*   **Tests**: Full test suite including unit tests for the model, server integration tests, and UI widget tests.

## 3. Proposed Solution
### RDF Data Model
The `Person` graph will utilize standard `schema.org` properties.

```turtle
@prefix schema: <https://schema.org/> .
@prefix api: <https://example.com/api/> .

api:persons/P1 a schema:Person ;
    schema:givenName "Jane" ;
    schema:familyName "Doe" ;
    schema:jobTitle "Engineer" .
```

### Validation
The `Person` class constructor and `fromDataset` factory will validate that `givenName`, `familyName`, and `jobTitle` are not all empty. If they are, it will throw an `ArgumentError` or validation exception.

## 4. Implementation Steps

### Phase 1: Vocabulary & Model
1.  Update `lib/api/models/vocab.dart` with `personClass`, `givenName`, `familyName`, and `jobTitle`.
2.  Create `lib/api/models/person.dart` implementing JSON serialization and `fromDataset`/`toDataset`. Add validation logic.
3.  Add DTOs to `lib/api/models/api_requests.dart`: `ListPersonsResponse`, `ListPersonsRequest`, `GetPersonRequest`, `CreatePersonRequest`, `UpdatePersonRequest`, `DeletePersonRequest`.

### Phase 2: Server & Router
1.  Create `lib/server/controllers/person_controller.dart` implementing CRUD operations for `Person`.
2.  Update `lib/server/router/server_router.dart` to handle `/persons` routes.

### Phase 3: Domain & Data Layers
1.  Create `lib/data/services/person_api_service.dart`.
2.  Create `lib/domain/repositories/person_repository.dart`.
3.  Create `lib/data/repositories/person_repository_impl.dart`.
4.  Create `lib/domain/usecases/`:
    *   `get_persons_usecase.dart`
    *   `save_person_usecase.dart`
    *   `delete_person_usecase.dart`

### Phase 4: UI & Navigation
1.  Create `lib/ui/viewmodels/person_list_viewmodel.dart` and `person_form_viewmodel.dart`.
2.  Create `lib/ui/views/person_list_screen.dart` and `person_form_screen.dart`.
3.  Update `lib/ui/router/app_router.dart` to instantiate ViewModels and add `/persons` routes.
4.  Update `lib/ui/views/app_shell.dart` to add a "People" destination to the `NavigationRail`.

### Phase 5: Testing
1.  Create `test/fakes/fake_person_repository.dart`.
2.  Add tests for `test/api/models/person_test.dart` (ensure validation is tested).
3.  Add `test/server/person_api_test.dart`.
4.  Add unit/widget tests for the Domain and UI layers.
5.  Run full test suite to ensure no regressions.

## 5. Verification
*   `flutter test` passes 100%.
*   `flutter analyze` reports no issues.
*   Manual verification via UI to create, edit, delete, and list Persons, ensuring validation correctly fires.