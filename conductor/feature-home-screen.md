# Feature Plan: Dashboard Home Screen

## 1. Background & Motivation
Currently, the application lands directly on the `TaskListScreen` at the root path (`/`). This obscures the rich, multi-domain nature of the application (Tasks, Persons, Organizations, Things). A dedicated Home Screen is needed to serve as a central hub, providing clear navigation and high-level metrics for all available domains.

## 2. Scope & Impact
*   **Routing (`lib/ui/router/app_router.dart`)**:
    *   Re-map the root path `/` to the new `HomeScreen`.
    *   Move the current `TaskListScreen` from `/` to `/lists`.
    *   Ensure the `AppShell` (navigation drawer/rail) highlights the correct selected index based on the new route structure.
*   **UI ViewModels (`lib/ui/viewmodels/home_screen_viewmodel.dart`)**: Create a new ViewModel responsible for fetching high-level metrics (counts) across all domains. It will need `GetTaskListsUseCase`, `GetPersonsUseCase`, `GetOrganizationsUseCase`, and `GetThingsUseCase`.
*   **UI Views (`lib/ui/views/home_screen.dart`)**: Create the new `HomeScreen` displaying a grid or list of cards. Each card will represent a domain, show an icon, the domain name, and the count of items (e.g., "5 Task Lists", "12 People"). Tapping a card navigates to the respective list screen.
*   **Shell Updates (`lib/ui/views/app_shell.dart`)**: Update the `NavigationRail` and `NavigationBar` destinations to include "Home" and update the "Task Lists" route.

## 3. Proposed Solution
### HomeScreenViewModel
The `HomeScreenViewModel` will have an `isLoading` state and integer properties for the counts: `taskListCount`, `personCount`, `organizationCount`, and `thingCount`. A `loadMetrics()` method will call all injected use cases (potentially using `Future.wait` for concurrent loading) and update the counts.

### HomeScreen UI
The `HomeScreen` will use a `LayoutBuilder` or `GridView` to present the domain cards responsively.
*   **Card Design**: Each card will have a distinctive color or icon, a large title (e.g., "People"), and a subtitle showing the metric (e.g., "12 Registered").
*   **Navigation**: Tapping a card uses `context.go()` to navigate to `/lists`, `/persons`, `/organizations`, or `/things`.

### Routing Adjustments
*   `/` -> `HomeScreen`
*   `/lists` -> `TaskListScreen` (formerly `/`)

## 4. Implementation Steps

### Phase 1: ViewModel Creation
1.  Create `lib/ui/viewmodels/home_screen_viewmodel.dart`.
2.  Inject the 4 "Get" UseCases.
3.  Implement `loadMetrics()` to fetch lists and set their `.length` to the respective count properties.

### Phase 2: View Creation
1.  Create `lib/ui/views/home_screen.dart`.
2.  Implement a `GridView.builder` or a simple `Wrap` of custom `Card` widgets for each domain.
3.  Bind the UI to the `HomeScreenViewModel` using `ListenableBuilder` to show loading indicators or the loaded metrics.
4.  Add `onTap` handlers to the cards for navigation.

### Phase 3: Routing and Shell Updates
1.  Update `lib/ui/router/app_router.dart`:
    *   Instantiate `HomeScreenViewModel`.
    *   Change the `/` route to build `HomeScreen`.
    *   Add a new `/lists` route to build `TaskListScreen`.
2.  Update `lib/ui/views/app_shell.dart`:
    *   Add a "Home" destination (icon: `Icons.home`).
    *   Update the logic for `_calculateSelectedIndex` and `_onItemTapped` to handle `/`, `/lists`, `/persons`, `/organizations`, and `/things`.

### Phase 4: Testing
1.  Create `test/ui/viewmodels/home_screen_viewmodel_test.dart` to verify `loadMetrics()`.
2.  Run `flutter analyze` and `flutter test` to ensure everything compiles and all 82+ tests pass.
3.  Manually verify navigation from Home to all other screens and back.