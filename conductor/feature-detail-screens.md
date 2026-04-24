# Feature Plan: Person and Organization Detail Screens

## 1. Background & Motivation
Currently, users can see a list of Persons and Organizations, and they can create, edit, or delete them. However, there is no dedicated "Detail" view to see the full information of a specific Person or Organization. Adding a detail screen will allow users to tap on a list tile to view all the properties (e.g., job title, legal name, URL) in a clean, read-only format.

## 2. Scope & Impact
*   **UI Views (`lib/ui/views/person_detail_screen.dart`, `lib/ui/views/organization_detail_screen.dart`)**: New stateless or stateful widgets to display the details of a `Person` or `Organization`.
*   **Navigation (`lib/ui/views/person_list_screen.dart`, `lib/ui/views/organization_list_screen.dart`)**: Wrap `ListTile` with an `onTap` handler to navigate to the new detail screens.
*   **Router (`lib/ui/router/app_router.dart`)**: Add `detail` sub-routes under `/persons` and `/organizations`.

## 3. Proposed Solution
When a user taps a tile on the `PersonListScreen` or `OrganizationListScreen`, the app will use `context.push()` to navigate to the respective detail screen. We will pass the selected `Person` or `Organization` object via the `extra` parameter in `go_router` to avoid a redundant network/database fetch, keeping the UI snappy. 

The Detail Screens will present the data using standard Material Design layouts (e.g., `Card` or a simple `Column` with `ListTile`s for each data point). We can also include an "Edit" FAB on the detail screen for quick access.

## 4. Implementation Steps

### Phase 1: Create Detail Screens
1.  Create `lib/ui/views/person_detail_screen.dart`. It will accept a `Person` object and display `givenName`, `familyName`, and `jobTitle`.
2.  Create `lib/ui/views/organization_detail_screen.dart`. It will accept an `Organization` object and display `displayName`, `type`, `legalName`, `description`, and `url`.

### Phase 2: Update Navigation and Routing
1.  Update `lib/ui/router/app_router.dart` to define:
    *   `/persons/detail` route.
    *   `/organizations/detail` route.
2.  Update `lib/ui/views/person_list_screen.dart` to add `onTap: () => context.push('/persons/detail', extra: person)` to the `ListTile`.
3.  Update `lib/ui/views/organization_list_screen.dart` to add `onTap: () => context.push('/organizations/detail', extra: organization)` to the `ListTile`.

### Phase 3: Testing
1.  Run `flutter analyze` to ensure no issues.
2.  Run `flutter test` to ensure existing tests pass.
3.  Manually verify the navigation flow in the app.