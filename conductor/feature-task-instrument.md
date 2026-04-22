# Feature Plan: Linking Tasks to Things (schema:instrument)

## 1. Background & Motivation
In accordance with `schema:Action`, our `Task` resource can have multiple `schema:instrument` properties pointing to `Thing` resources that are used to perform the action. The user needs to associate one or more `Things` with a `Task` at the time of creation. Because the list of `Things` could be large, a standard dropdown is insufficient. A multi-select, searchable UI component is required within the creation flow.

## 2. Scope & Impact
*   **API Model (`lib/api/models/task.dart`)**: Add `List<String> instruments` field to represent the URIs of associated `Things`. Update `toDataset` and `fromDataset` to handle the `schema:instrument` property.
*   **Domain & Data (`TaskRepository`, `AddTaskToListUseCase`, `TaskApiService`)**: Update creation and update methods to accept and transmit the list of instruments.
*   **UI ViewModels (`TaskScreenViewModel`)**: Inject `GetThingsUseCase` so the view model can query available `Things` for selection. Add state to hold the list of available `Things` or implement a search method.
*   **UI Views (`TaskScreen`, `TaskScreenDialog`)**: Refactor the basic `AlertDialog` into a more robust `StatefulWidget` (e.g., a BottomSheet or an expanded Dialog) that includes:
    *   A text field for the Task name.
    *   A searchable list/autocomplete section to find and select multiple `Things`.
    *   Visual representation (e.g., `Chip` widgets) of currently selected `Things`.

## 3. Proposed Solution
### RDF Data Model
The `Task` graph will be expanded to include multiple `vocab:instrument` (`schema:instrument`) triples.

```turtle
@prefix schema: <https://schema.org/> .
@prefix api: <https://example.com/api/> .

api:tasks/T1 a schema:Action ;
    schema:name "Write Code" ;
    schema:instrument api:things/laptop ;
    schema:instrument api:things/coffee .
```

### UI Implementation
Instead of a simple `AlertDialog`, we will implement a custom `StatefulWidget` for the creation dialog (`CreateTaskDialog`). This dialog will contain:
1.  **Task Name Input**: Standard `TextField`.
2.  **Instrument Search**: A `SearchAnchor` or an `Autocomplete` field that queries the `TaskScreenViewModel` for `Things` matching the input.
3.  **Selected Instruments**: A `Wrap` of `InputChip` widgets representing the chosen `Things`. The user can tap the 'X' on a chip to remove it.

## 4. Implementation Steps

### Phase 1: Model & Domain Updates
1.  Update `Task` class with `final List<String> instruments;`. Update JSON serialization and `Dataset` parsing/generation.
2.  Update `TaskRepository`, `TaskRepositoryImpl`, and `TaskApiService` to pass the `instruments` data.
3.  Update `AddTaskToListUseCase` and `SaveTaskUseCase` to handle `instruments`.

### Phase 2: ViewModel Updates
1.  Inject `GetThingsUseCase` into `TaskScreenViewModel` (and update `lib/app.dart` to provide it).
2.  Add a `searchThings(String query)` method to `TaskScreenViewModel` to support the UI's autocomplete functionality.

### Phase 3: UI Updates
1.  Create a new widget `CreateTaskDialog` (or `CreateTaskBottomSheet`) in `lib/ui/views/`.
2.  Implement the multi-select searchable interface.
3.  Update `TaskScreen`'s `FloatingActionButton` to launch this new widget.
4.  Update the `TaskScreen` list items to display the selected instruments (e.g., as small chips below the task description).

### Phase 4: Testing
1.  Update `FakeTaskRepository` and `FakeThingRepository`.
2.  Update unit tests in `test/api/models/task_test.dart` for the new `instruments` field.
3.  Update `test/ui/views/task_screen_test.dart` to cover the new multi-select dialog flow.