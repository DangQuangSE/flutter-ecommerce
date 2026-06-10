# Phase 4: Images Step

## Requirements
Replace the Step 3 placeholder with a functional image management view that uses the existing `AdminProductImageCubit` and `image_picker` to let the admin pick images from the device gallery, see upload progress and thumbnails, delete images, and complete the form flow by navigating back to the product list.

Covers: **FR-08**, **P1 story: upload product images**

## Steps
1. Build the `_Step3ImagesForm` private widget as a `StatelessWidget` that reads `AdminProductImageCubit` state. Render a `Wrap` or `GridView` of thumbnail tiles for images already in `AdminProductImageSuccess.images` — each tile shows the image URL in a `CachedNetworkImage` (or plain `Image.network`) and a delete icon overlay.

2. Add an "Add Image" tile (camera/plus icon) at the start of the grid that, when tapped, calls `ImagePicker().pickMultiImage()` and then iterates the selected files, calling `cubit.addImage(productId, file)` for each one sequentially. Derive `productId` the same way as Phase 3: `formState.createdProductId ?? formState.editingId!`.

3. Display upload progress: when `AdminProductImageState` is `AdminProductImageUploading`, show a `LinearProgressIndicator` above the grid with `value: state.progress`. When state is `AdminProductImageSuccess` or `AdminProductImageInitial`, hide the progress bar.

4. Handle delete: tapping the delete overlay on a tile calls `cubit.deleteImage(image.id)`. Show a transient error snackbar on `AdminProductImageFailure`.

5. Add navigation buttons at the bottom: "Quay lại" calls `formCubit.goBack()` (returns to Step 2). "Hoàn tất" button is always enabled (images are optional) — it shows a loading state from `formCubit.state.isSubmitting` if needed, then calls a new `formCubit.completeForm()` method that emits `isSuccess: true` to trigger the existing BlocListener which calls `context.pop()` and shows the success snackbar.

6. Update the `AdminProductFormPage` BlocListener for `isSuccess`: confirm it only triggers `context.pop()` when `state.currentStep == 2` (Step 3) — this prevents false dismissal from any intermediate success states. Replace the Step 3 placeholder in `IndexedStack` with this widget.

## Success Criteria
- Entering Step 3 shows the image grid (empty initially in create mode).
- Tapping "Add Image" opens the device gallery picker; selecting one or more images triggers sequential upload calls; each uploaded image appears as a thumbnail in the grid.
- The `LinearProgressIndicator` is visible during upload and disappears on completion.
- Tapping a thumbnail's delete icon removes it from the grid.
- Tapping "Hoàn tất" navigates back to the product list and shows "Tạo sản phẩm thành công" (create) or "Cập nhật sản phẩm thành công" (edit) snackbar.
- Tapping "Quay lại" returns to Step 2 without resetting any variant data.

## Risks
- `ImagePicker.pickMultiImage()` returns an empty list (not an error) if the user cancels — guard with an early return to avoid calling `addImage` with 0 files.
- Sequential upload (one file at a time) means the progress indicator reflects the current file's progress, not overall progress. This is acceptable for P1 but should be noted in a code comment so it is not mistaken for a bug.
- The existing `BlocListener` for `isSuccess` currently calls `context.pop()` unconditionally — if Phase 2 does not gate it to `currentStep == 2`, this phase must fix it to avoid premature navigation.
