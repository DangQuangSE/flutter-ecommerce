# Real-time Bug Fix & Push Notification Plan

Tôi đã tìm ra nguyên nhân gây lỗi tin nhắn chat không nhận được real-time qua WebSocket và đã tổng hợp chung với tính năng Push Notification (cùng yêu cầu điều hướng) mà bạn vừa confirm.

## Nguyên nhân lỗi Real-time Chat
Khi Spring Boot trả data qua REST API (ví dụ load tin nhắn ban đầu), nó dùng `ObjectMapper` chuẩn của web, convert `LocalDateTime` thành String (ISO 8601). Tuy nhiên, khi gửi qua **WebSocket (STOMP)**, Spring sử dụng một default `ObjectMapper` khác, serialize biến `createdAt` thành dạng Object/Array (ví dụ: `{"dayOfMonth":2, ...}`). 
Điều này làm cho Flutter app khi parse `json['createdAt'] as String?` bị crash `TypeError` ngầm và vứt bỏ hoàn toàn tin nhắn đó.

## Đề xuất thay đổi

### 1. Fix Bug WebSocket Serialization (Backend)
Sử dụng `@JsonFormat` để ép Jackson luôn parse `LocalDateTime` thành String chuẩn ISO trên mọi object trả về qua WebSocket.

#### [MODIFY] [MessageResponse.java](file:///d:/FPT/8thSemester/PRM393/be-ecommerce/src/main/java/com/sport_pro_be/modules/chat/dto/MessageResponse.java)
- Thêm annotation `@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")` vào thuộc tính `createdAt`.

#### [MODIFY] [ConversationResponse.java](file:///d:/FPT/8thSemester/PRM393/be-ecommerce/src/main/java/com/sport_pro_be/modules/chat/dto/ConversationResponse.java)
- Thêm annotation `@JsonFormat` tương tự cho `lastMessageAt`.

### 2. Xử lý Navigation khi bấm vào Notification (Frontend)
Để điều hướng khi bấm vào thông báo, chúng ta cần truyền `payload` vào notification và lắng nghe sự kiện tap.

#### [MODIFY] [notification_service.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/core/utils/notification_service.dart)
- Thêm `payload` vào hàm `showNotification`.
- Khai báo một `StreamController<String> payloadStream` để phát ra payload khi `onDidReceiveNotificationResponse` được gọi.

#### [MODIFY] [app.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/app/app.dart)
- Lắng nghe `sl<NotificationService>().payloadStream` trong `initState` hoặc qua một `StreamListener`. Khi có payload dạng `/chat/{id}` hoặc `/orders/{id}`, dùng `AppRouter.router.push(payload)` để chuyển hướng.

### 3. Logic hiển thị Notification cho Chat và Customer (Frontend)

#### [MODIFY] [chat_cubit.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/chat/presentation/cubit/chat_cubit.dart)
- Truyền `NotificationService` vào constructor.
- Trong `_onIncomingMessage()`, nếu `!isViewingRoom`, gọi `showNotification` kèm payload là link phòng chat: `/chat/${conversationId}`.

#### [MODIFY] [chat_module.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/chat/chat_module.dart)
- Inject `sl<NotificationService>()` vào `ChatCubit`.

#### [MODIFY] [notification_cubit.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/notification/presentation/cubit/notification_cubit.dart)
- Tương tự như ChatCubit, tiêm `NotificationService`.
- Trong listener của `_socketClient.notifications`, gọi `showNotification()` với payload điều hướng (chẳng hạn `/orders/{relatedId}`).

#### [MODIFY] [notification_module.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/notification/notification_module.dart)
- Inject `sl<NotificationService>()` vào `NotificationCubit`.

## Verification Plan
### Manual Verification
- Chạy Backend, login Flutter app bằng tài khoản Customer.
- Gửi tin nhắn qua lại. Kiểm tra xem phía nhận đã realtime có tin nhắn mới ngay mà không cần reload trang hay không (Bug Fix).
- Ẩn ứng dụng xuống nền (hoặc ở ngoài phòng chat), gửi tin nhắn. Kiểm tra Push Notification hiện lên, nhấn vào Push Notification để bay thẳng vào `/chat/{id}`.
- Đặt 1 đơn hàng mới (hoặc update status), kiểm tra Notification đẩy lên và nhấn vào nhảy vào chi tiết đơn hàng.
