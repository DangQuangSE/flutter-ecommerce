# Fix Cancel Loading & Hibernate Warning

## Scope Challenge
- **Exists?**: Yes, this is a bug fix for the newly added Cancel Order feature.
- **Minimum?**: Remove conflicting BLoC events causing UI state bugs, and optimize the backend pagination query if needed.
- **Complexity?**: **Fast** (simple state conflict in one file, single backend query warning).

## Root Cause Analysis
1. **Frontend UI Loading Bug**: 
   Khi thực hiện `CancelOrderRequested`, trong `OrderBloc` phát ra event `OrderListRequested()` (để làm mới danh sách đơn hàng). Tuy nhiên, trang `OrderDetailPage` dùng chung `OrderBloc` này, và `BlocBuilder` của trang chi tiết KHÔNG XỬ LÝ trạng thái `OrderListLoaded`. Do đó, khi state chuyển sang `OrderListLoaded`, nhánh mặc định `_ => const AppLoadingView()` được gọi, dẫn đến màn hình xoay vô tận. 
   Thêm nữa, trong UI cũng gọi `OrderDetailRequested` khi cancel thành công tạo ra một Race Condition giữa việc load chi tiết và load danh sách.
2. **Backend Hibernate Warning**: `HHH90003004: firstResult/maxResults specified with collection fetch; applying in memory`
   Khi gọi API lấy danh sách đơn hàng (`OrderListRequested`), Backend thực hiện query có phân trang (firstResult/maxResults) đi kèm với `JOIN FETCH` collection (vd: `items`). Hibernate không thể phân trang trực tiếp bằng SQL với JOIN FETCH collection, nên nó kéo TOÀN BỘ dữ liệu vào bộ nhớ rồi mới phân trang, gây ảnh hưởng hiệu năng.

## Phase 1: Frontend - Fix UI State Conflict
**File**: `lib/features/order/presentation/bloc/order_bloc.dart`
- Remove `add(const OrderListRequested());` from `_onCancelOrderRequested`.
- Chỉnh lại để khi Cancel thành công, chỉ trả về state `CancelOrderSuccess(order: data)`. Việc refresh chi tiết đã được `BlocListener` ở `order_detail_page.dart` lo liệu bằng `OrderDetailRequested`.
- Khi người dùng ấn quay lại trang danh sách, trang danh sách có thể dùng pull-to-refresh hoặc `didPop` để tải lại danh sách nếu cần, hoặc chấp nhận việc danh sách tự tải lại khi được focus.

## Phase 2: Backend - Fix Pagination In-Memory (Tùy chọn)
**File**: `src/main/java/com/sport_pro_be/modules/order/repository/OrderRepository.java` (hoặc cấu hình Entity)
- Để fix `HHH90003004`, chúng ta có thể tách câu query thành 2 bước (lấy ID trước rồi fetch sau), hoặc sử dụng `@BatchSize` trên collection `items` thay vì `JOIN FETCH` trong câu query phân trang.
- Vì đây là cảnh báo warning, nếu chưa gây lỗi nghiêm trọng, ta có thể ưu tiên fix Frontend trước. Tuy nhiên, nếu user muốn fix luôn, ta sẽ cấu hình `@BatchSize`.
