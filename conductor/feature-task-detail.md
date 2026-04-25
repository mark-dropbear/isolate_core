# Feature Plan: Task Detail Screen

## 1. Background & Motivation
As `Task` resources (mapping to `schema:Action`) have become more complex, storing information about `schema:instrument` (Things) and `schema:agent` (Persons/Organizations), as well as properties like `schema:endTime` and `schema:actionStatus`, there is a need for a dedicated "Task Detail" view to see all this information clearly.

## 2. Scope & Impact
*   **UI Views (`lib/ui/views/task_detail_screen.dart`)**: New screen to display the properties of a single `Task`. It should render the task's name, description, completion status, completion time, instruments, and agents.
*   **Routing (`lib/ui/router/app_router.dart`)**: Add a `detail` sub-route under `/tasks/:listName`.
*   **Navigation (`lib/ui/views/task_screen.dart`)**: Make the `ListTile` for tasks tappable. `onTap` will navigate to the detail screen via `context.push()`. 
*   **Data Presentation**: Because the `Task` model stores instruments and agents as URIs, the detail screen will need to resolve these into human-readable display names. To keep it simple and efficient, we will pass the pre-loaded `availableThings`, `availablePersons`, and `availableOrganizations` from the `TaskScreenViewModel` into the `TaskDetailScreen`, alongside the `Task` itself.

## 3. Proposed Solution
When a user taps a task tile on the `TaskScreen`, the app navigates to `/tasks/:listName/detail`. We will pass a data payload in the router's `extra` parameter containing:
1.  The `Task` object.
2.  The list of `availableThings`.
3.  The list of `availablePersons`.
4.  The list of `availableOrganizations`.

The `TaskDetailScreen` will read this payload and cleanly present:
*   A header with the `displayName`.
*   A "Status" row indicating "Completed" (with its `endTime` formatted) or "Potential".
*   A "Description" row.
*   An "Instruments" wrap displaying the resolved `Thing` names with icons.
*   An "Agents" wrap displaying the resolved `Person` or `Organization` names with their respective icons.

## 4. Implementation Steps

### Phase 1: Create Detail Screen
1.  Create a payload class or simply a `Map` to pass the necessary data. For type safety, we'll create a `TaskDetailPayload` class in `task_detail_screen.dart`.
2.  Create `lib/ui/views/task_detail_screen.dart` (a `StatelessWidget`) accepting this payload.
3.  Implement `_buildDetailRow` and `_buildChipList` helpers inside the view to present the task's properties. Include logic to resolve the display names of instruments and agents from the provided lists.

### Phase 2: Update Navigation and Routing
1.  Update `lib/ui/router/app_router.dart`: Add `GoRoute(path: 'detail')` under the `/tasks/:listName` route. The builder extracts `state.extra as TaskDetailPayload` and passes it to the screen.
2.  Update `lib/ui/views/task_screen.dart`: Add an `onTap` handler to the `ListTile`. It will construct a `TaskDetailPayload` with the task and the lists from `widget.viewModel`, then call `context.push('/tasks/${Uri.encodeComponent(widget.listName)}/detail', extra: payload)`.

### Phase 3: Testing
1.  Run `flutter analyze` to ensure strict typing and no unused imports.
2.  Run `flutter test` to verify no regressions in the current suite.
3.  Manual verification: create a task with agents and instruments, complete it, and click to view the details screen to confirm everything resolves and displays correctly.