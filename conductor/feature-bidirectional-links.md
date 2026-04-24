# Feature Plan: Bidirectional Linking of Person and Organization

## 1. Background & Motivation
The user needs to associate a `Person` with an `Organization`. In Schema.org, a Person has a `schema:worksFor` property pointing to an Organization, and an Organization has a `schema:employee` property pointing to a Person. 
When a link is created from either side (e.g., adding an Organization to a Person's `worksFor` field), the system must automatically create the reciprocal link (adding the Person to the Organization's `employee` field).

## 2. Scope & Impact
*   **Vocabulary (`lib/api/models/vocab.dart`)**: Add `worksFor` and `employee`.
*   **Models (`lib/api/models/person.dart`, `lib/api/models/organization.dart`)**: Add `List<String> worksFor` to `Person` and `List<String> employees` to `Organization`. Include these in `toDataset`, `fromDataset`, `fromJson`, `toJson`, and `copyWith`.
*   **API Services & Repositories**: Ensure `worksFor` and `employee` are propagated via `updateMask`.
*   **Backend Sync Logic**: The `PersonController` and `OrganizationController` must determine diffs (added/removed links) during `POST` and `PATCH` requests and directly modify the related resources' datasets in `ResourceStorage` to preserve bidirectional symmetry.
*   **UI Forms**:
    *   `PersonFormScreen`: Add multi-select for Organizations (requires injecting `GetOrganizationsUseCase` into `PersonFormViewModel`).
    *   `OrganizationFormScreen`: Add multi-select for Persons (requires injecting `GetPersonsUseCase` into `OrganizationFormViewModel`).
*   **UI Details**:
    *   Update `PersonDetailScreen` to show linked organizations.
    *   Update `OrganizationDetailScreen` to show linked employees.

## 3. Proposed Solution
### RDF Data Model Symmetry
When a Person `api:persons/P1` works for Organization `api:organizations/O1`:
- `P1`'s graph contains: `<api:persons/P1> <schema:worksFor> <api:organizations/O1>`
- `O1`'s graph contains: `<api:organizations/O1> <schema:employee> <api:persons/P1>`

### Backend Synchronization
We will implement helper methods in the Isolate Server controllers (or a shared utility) that run after a resource is saved:
1.  **For Person Updates**: Compare the old `worksFor` list with the new `worksFor` list. 
    *   For each *added* organization: Load the organization's graph, add the `schema:employee` quad pointing to the person, and save.
    *   For each *removed* organization: Load the organization's graph, remove the `schema:employee` quad pointing to the person, and save.
2.  **For Organization Updates**: Perform the inverse logic for the `employees` list, adding/removing `schema:worksFor` quads from the relevant persons' graphs.

## 4. Implementation Steps

### Phase 1: Vocabulary & Models
1.  Update `Vocab` with `worksFor` and `employee`. Add them to `mapFieldsToPredicates`.
2.  Update `Person` to include `worksFor` and `Organization` to include `employees`.

### Phase 2: Backend Controllers (Bidirectional Sync)
1.  Update `PersonController` to calculate differences in `worksFor` before and after updates, modifying the associated `Organization` datasets via `ResourceStorage`.
2.  Update `OrganizationController` to calculate differences in `employees` before and after updates, modifying the associated `Person` datasets via `ResourceStorage`.
3.  Add unit tests in `test/server/` to verify bidirectional linking behaves correctly when modifying either side.

### Phase 3: Domain & UI
1.  Update `PersonRepository` and `OrganizationRepository` to accept the new fields in `create` methods, and add the fields to their `updateMask` arrays.
2.  Update `PersonFormViewModel` to load available organizations and manage the selected `worksFor` links.
3.  Update `OrganizationFormViewModel` to load available persons and manage the selected `employees` links.
4.  Update `PersonFormScreen` and `OrganizationFormScreen` with `FilterChip` wrap lists (similar to the Task instruments implementation).
5.  Update `PersonDetailScreen` and `OrganizationDetailScreen` to show the connected entities.

### Phase 4: Testing
1.  Update `FakePersonRepository` and `FakeOrganizationRepository` to handle the new lists (simulating the bidirectional sync for UI tests if necessary, or just storing the lists).
2.  Update unit tests in `test/api/models/`.
3.  Run all tests to ensure no regressions and verify the bidirectional backend synchronization.