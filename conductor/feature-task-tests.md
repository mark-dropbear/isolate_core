# Feature Plan: Test Suite - Fakes & Unit Tests (Tasks)

## 1. Background & Motivation
To align the new `Task` and `TaskList` features with the project's testing standards (`flutter-testing-apps`), we need to implement robust client-side testing. The priority is to create `Fake` repositories and use them to test the Domain UseCases and UI ViewModels, ensuring logic is verified in isolation without relying on the real backend isolate or network transport.

## 2. Scope & Impact
*   **Fakes (`test/fakes/`)**: Implement `FakeTaskRepository` and `FakeTaskListRepository`.
*   **Domain Tests (`test/domain/usecases/`)**: Implement unit tests for all Task and TaskList UseCases.
*   **ViewModel Tests (`test/ui/viewmodels/`)**: Implement unit tests for `TaskListViewModel` and `TaskScreenViewModel`.

## 3. Proposed Solution
### Fakes
We will mirror the `FakeThingRepository` pattern. 
*   `FakeTaskRepository`: Manages an in-memory list of `Task` objects.
*   `FakeTaskListRepository`: Manages an in-memory list of `TaskList` objects and accurately simulates the `addTaskToList`, `removeTaskFromList`, and `getTasksForList` logic.

### Domain Unit Tests
We will verify that each UseCase correctly calls the underlying Repository methods and handles logic (like routing empty names to `create` vs. populated names to `update` in `SaveTaskUseCase`).

### ViewModel Unit Tests
We will verify state transitions (`isLoading`, `error`) and that UI actions (like `toggleTaskStatus` or `createTaskList`) properly invoke the UseCases and update the exposed properties (`tasks`, `taskLists`).

## 4. Implementation Steps

### Phase 1: Fakes
1.  Create `test/fakes/fake_task_repository.dart` implementing `TaskRepository`. Includes a `seed(List<Task>)` method.
2.  Create `test/fakes/fake_task_list_repository.dart` implementing `TaskListRepository`. Includes a `seed(List<TaskList>)` method and requires a `FakeTaskRepository` instance to accurately resolve `getTasksForList` requests based on `TaskListItem` references.

### Phase 2: Domain Unit Tests
1.  Create `test/domain/usecases/task_usecases_test.dart` for `SaveTaskUseCase`.
2.  Create `test/domain/usecases/task_list_usecases_test.dart` for `GetTaskListsUseCase`, `GetTasksForListUseCase`, `SaveTaskListUseCase`, and `AddTaskToListUseCase`.

### Phase 3: ViewModel Unit Tests
1.  Create `test/ui/viewmodels/task_list_viewmodel_test.dart`. Test `loadTaskLists`, `createTaskList`, and error handling. (Mock the `DebugApiService` for the clipboard functionality if necessary, or just test the core logic).
2.  Create `test/ui/viewmodels/task_screen_viewmodel_test.dart`. Test `loadTasks`, `addTask`, and `toggleTaskStatus`.

## 5. Verification & Testing
*   Execute `flutter test` to ensure all new unit tests pass alongside the existing suite, achieving 100% pass rate.