# Phase 4: Flutter Presentation

## Requirements
Deliver the complete admin UI for size group management: a cubit exposing all five canonical states, a list screen with delete confirmation, a form screen supporting create/edit with an inline dynamic size-option editor, decomposed sub-widgets, GoRouter routes wired correctly, and DI registration for the cubit.

Feature root: `lib/features/size/presentation/` (consistent with Phases 2–3).

## Steps

1. **Create `SizeGroupCubit` and `SizeGroupState`** in `lib/features/size/presentation/cubit/`:
   - `size_group_state.dart` — sealed class hierarchy: `SizeGroupInitial`, `SizeGroupLoading`, `SizeGroupSuccess(List<SizeGroupEntity> groups, {String? message})`, `SizeGroupError(String message)`, `SizeGroupEmpty`. `SizeGroupSuccess` includes an optional feedback message for snackbar display after mutations.
   - `size_group_cubit.dart` — methods: `loadSizeGroups()`, `createSizeGroup(SizeGroupEntity)`, `updateSizeGroup(int id, SizeGroupEntity)`, `deleteSizeGroup(int id)`. After each successful mutation, re-fetch the list and emit `SizeGroupSuccess` with a message. Mirror the `BrandCubit` approach.

2. **Create `AdminSizeGroupListPage`** in `lib/features/size/presentation/pages/admin_size_group_list_page.dart`:
   - Scaffold with AppBar and a floating action button that navigates to the create form via `context.push(AppRoutes.adminSizeGroupCreate)`.
   - Use `BlocConsumer` — `listener` shows a snackbar on success message or error; `builder` renders: `SizeGroupLoading` → `CircularProgressIndicator`, `SizeGroupError` → error widget with retry, `SizeGroupEmpty` → empty state with prompt, `SizeGroupSuccess` → `ListView.builder` of `SizeGroupCard` widgets.
   - The `build()` method must stay under 50 lines; extract loading/error/empty/list builders as private helper methods or widgets.

3. **Create `SizeGroupCard` widget** in `lib/features/size/presentation/widgets/size_group_card.dart`:
   - Displays group name, optional description, and a comma-separated preview of size option names (ordered by `displayOrder`).
   - Contains an edit icon button (navigates to the edit form via `context.push(AppRoutes.adminSizeGroupEdit(group.id!))`) and a delete icon button (shows a confirm `AlertDialog` before calling cubit's `deleteSizeGroup`).
   - All tap handlers delegate to cubit methods — no inline logic.

4. **Create `AdminSizeGroupFormPage`** in `lib/features/size/presentation/pages/admin_size_group_form_page.dart`:
   - Accepts an optional `SizeGroupEntity? initialGroup` — null means create mode, non-null means edit mode. Title adjusts accordingly.
   - Contains `TextFormField` for name (required, max 100 chars) and description (optional, max 255 chars).
   - Embeds a `SizeOptionListEditor` widget for managing the sizes list.
   - A Save button calls `cubit.createSizeGroup` or `cubit.updateSizeGroup` depending on mode, then pops on success (listen to state via `BlocListener`).
   - Local form state (TextEditingControllers, form key, sizes list) is managed with `StatefulWidget` / `setState` — purely ephemeral UI state scoped to this single screen, correct per grading rules.
   - The `build()` method must stay under 50 lines; extract the name field, description field, sizes editor, and action button as private widgets.

5. **Create `SizeOptionListEditor` and `SizeOptionEditorRow` widgets** in `lib/features/size/presentation/widgets/`:
   - `size_option_list_editor.dart` — takes a `List<SizeOptionDraft>` (a lightweight local model: `name` + `displayOrder`) and callbacks (`onAdd`, `onRemove(int index)`, `onChanged(int index, SizeOptionDraft updated)`). Renders `Column` of `SizeOptionEditorRow` widgets plus an "Add size" `TextButton`. Uses `setState`-driven local list in the parent.
   - `size_option_editor_row.dart` — one row per size option: a text field for the name (with `TextEditingController`), an integer text field for `displayOrder`, and a delete `IconButton`. Calls `onChanged` when either field changes. 
   - `SizeOptionDraft` — a small plain Dart class (not Equatable): `{String name, int displayOrder}`. Lives alongside the editor widget.

6. **Wire GoRouter routes** — add constants to `AppRoutes` and two `GoRoute` entries to `app_router.dart`:

   **Cubit sharing strategy:** Use **separate cubit factory per route** (consistent with how `AdminProductFormCubit` works). The form page creates its own cubit instance; after a successful save, it pops — and the list page's cubit calls `loadSizeGroups()` inside `initState` / `onResume` so the list refreshes. This avoids `ShellRoute` complexity.

   **Route structure** (critical — `/create` must come before `/:id` to avoid GoRouter matching "create" as an id):
   ```
   GoRoute(
     path: '/admin/size-groups',
     builder: (_, __) => BlocProvider(
       create: (_) => sl<SizeGroupCubit>()..loadSizeGroups(),
       child: const AdminSizeGroupListPage(),
     ),
     routes: [
       GoRoute(
         path: 'create',       ← nested child, matched before ':id'
         builder: ...,
       ),
       GoRoute(
         path: ':id/edit',     ← parameterized child — never shadows 'create'
         builder: (context, state) {
           final id = int.tryParse(state.pathParameters['id'] ?? '');
           // pass the existing group via state.extra or re-load by id
           ...
         },
       ),
     ],
   )
   ```
   - `AppRoutes.adminSizeGroups = '/admin/size-groups'`
   - `AppRoutes.adminSizeGroupCreate = '/admin/size-groups/create'`
   - `AppRoutes.adminSizeGroupEdit(int id) = '/admin/size-groups/$id/edit'`
   - Register `SizeGroupCubit` as `Factory` in `injection_container.dart` (see Phase 3 Step 4 placeholder).

## Success Criteria
- Navigating to `/admin/size-groups` shows the list (or empty state) — no crashes, no analyzer errors.
- Navigating to `/admin/size-groups/create` correctly opens the form page (NOT a 404 or incorrect route match).
- Creating a size group with at least two size options saves correctly and the list refreshes with a success snackbar after popping the form.
- Editing a group pre-fills the form with existing name, description, and size options; save replaces the options correctly.
- Tapping delete shows a confirmation dialog; confirming removes the group; cancelling leaves it in place.
- All new `.dart` files pass `dart analyze` with zero errors.
- `flutter build apk --debug` succeeds.

## Risks
- `SizeOptionListEditor` manipulates a mutable list inside a `StatefulWidget` — ensure the parent passes a fresh copy of sizes on init, not a reference to an entity's immutable list (use `List.from(entity.sizes)`).
- GoRouter nested route for edit parses `state.pathParameters['id']` as an int — handle null/invalid parse gracefully (redirect to list or show error), the same way existing admin routes handle invalid ids.
- List page refresh on pop: call `cubit.loadSizeGroups()` in the `onResume` / `didChangeDependencies` override or use a `GoRouter` redirect callback — whichever matches the pattern used by other admin list pages.
