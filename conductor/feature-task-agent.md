# Feature Plan: Linking Task with Agents (schema:agent)

## 1. Background & Motivation
A `Task` (which maps to `schema:Action`) needs an `agent` property to represent the entity performing the action. In Schema.org, `schema:agent` can point to a `Person` or an `Organization`. These links do not need to be bi-directional, meaning the `Person` or `Organization` does not necessarily need a reciprocal link back to the `Task`.

## 2. Scope & Impact
*   **Vocabulary (`lib/api/models/vocab.dart`)**: Add `schema:agent`.
*   **Models (`lib/api/models/task.dart`)**: Add `List<String> agents` field to the `Task` class. Update `fromJson`, `toJson`, `fromDataset`, `toDataset`, and `copyWith`.
*   **API Services & Repositories (`lib/data/repositories/task_repository_impl.dart`, `lib/domain/repositories/task_repository.dart`)**: Add `agents` to `createTask` parameters and `updateMask`.
*   **UseCases (`lib/domain/usecases/add_task_to_list_usecase.dart`, `lib/domain/usecases/save_task_usecase.dart`)**: Propagate `agents` parameter.
*   **UI ViewModels (`lib/ui/viewmodels/task_screen_viewmodel.dart`)**: Inject `GetPersonsUseCase` and `GetOrganizationsUseCase`. Combine them into a list of available agents for selection.
*   **UI Views (`lib/ui/views/task_screen.dart`)**: Update `CreateTaskDialog` to include a multi-select list (e.g. `FilterChip`s) of combined `Person` and `Organization` resources to select as agents. Update the `Task` list tile to display selected agents.
*   **Routing (`lib/ui/router/app_router.dart`)**: Inject the new UseCases into `TaskScreenViewModel`.

## 3. Proposed Solution
### RDF Data Model
The `Task` graph will include multiple `schema:agent` triples pointing to either a `Person` or `Organization` IRI.

```turtle
@prefix schema: <https://schema.org/> .
@prefix api: <https://example.com/api/> .

api:tasks/T1 a schema:Action ;
    schema:name "Write Code" ;
    schema:agent api:persons/P1 ;
    schema:agent api:organizations/O1 .
```

### UI Implementation
The `TaskScreenViewModel` will load both `Person`s and `Organization`s and expose them (either as two separate lists or one combined wrapper class) so `CreateTaskDialog` can render chips for them. We will use two separate `Wrap` sections (one for People, one for Organizations) or one unified list if they share a common interface. For simplicity, we can just use two `Wrap` sections or map them into a `List<AgentItem>` wrapper that holds the URI and display name.

## 4. Implementation Steps

### Phase 1: Vocabulary & Model Updates
1.  Update `Vocab` with `agent = NamedNode('${schemaPrefix}agent')` and add it to `mapFieldsToPredicates`.
2.  Update `Task` class with `final List<String> agents`.
3.  Update `TaskRepository` and `TaskRepositoryImpl` to pass `agents`. Update `updateMask`.
4.  Update `AddTaskToListUseCase` and `SaveTaskUseCase` to handle `agents`.

### Phase 2: ViewModel Updates
1.  Update `app_router.dart` to pass `getPersonsUseCase` and `getOrganizationsUseCase` to `TaskScreenViewModel`.
2.  Update `TaskScreenViewModel` to load `Person`s and `Organization`s. Create lists `availablePersons` and `availableOrganizations`. Add `agents` parameter to `addTask`.

### Phase 3: UI Updates
1.  Update `CreateTaskDialog` in `lib/ui/views/task_screen.dart` to show a section for "Agents". Display `FilterChip`s for `availablePersons` and `availableOrganizations`.
2.  Update `TaskScreen` list items to display the selected agents alongside the instruments.

### Phase 4: Testing
1.  Update `FakeTaskRepository` to accept `agents`.
2.  Update `task_test.dart` to verify `agents` logic in model.
3.  Update `task_screen_test.dart` and `task_screen_viewmodel_test.dart` to handle the new injected UseCases and `agents` property.
4.  Run all tests to ensure they pass.