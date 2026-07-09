# Chat Push Notification Implementation Plan

This plan details how to display a local push notification (in-app banner/system notification) when a new chat message arrives from the WebSocket, similar to how Admin notifications currently behave.

## Proposed Changes

### Presentation Layer & Dependency Injection

#### [MODIFY] [chat_cubit.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/chat/presentation/cubit/chat_cubit.dart)
- Inject `NotificationService` into the constructor.
- Inside `_onIncomingMessage()`, if the user is **not** currently viewing the chat room (`!isViewingRoom`), call `_notificationService.showNotification(...)` to display the incoming message.

#### [MODIFY] [chat_module.dart](file:///d:/FPT/8thSemester/PRM393/flutter-ecommerce/lib/features/chat/chat_module.dart)
- Update the registration of `ChatCubit` to inject `sl<NotificationService>()`.

## Validation

### Manual Verification
- Start the application and log in.
- Navigate out of the chat screen (e.g., stay on Home or Dashboard).
- Send a message from the other party (e.g., Admin sends a message to Customer).
- Verify that a local push notification appears at the top of the screen with the message content.
- Ensure that if the user is *inside* the active chat room, the notification does NOT pop up.
