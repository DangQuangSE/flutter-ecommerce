# Phase 3: Flutter — Deep Link + WebView Payment Screen

**Goal:** App mở VNPay trong WebView; bắt redirect `sportpro://payment-result` và parse params.

**Covers:** US-2, US-3 (P1); US-6 (P2)

**Dependencies:** Phase 1 (cần paymentUrl thật để test)

---

## Tasks

### Dependencies
- [ ] `pubspec.yaml`: thêm `webview_flutter`, `app_links`

### Deep Link Config
- [ ] **Android** `AndroidManifest.xml` — intent-filter trên MainActivity:
  ```xml
  <intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="sportpro" android:host="payment-result"/>
  </intent-filter>
  ```
- [ ] **iOS** `Info.plist` — CFBundleURLTypes:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array><string>sportpro</string></array>
    </dict>
  </array>
  ```

### Payment Feature (presentation layer)
- [ ] `VnpayPaymentPage` — full-screen WebView
  - Input: `paymentUrl`, `orderId`
  - `NavigationDelegate.onNavigationRequest`: nếu URL starts with `sportpro://payment-result` → parse query, pop với result
  - Loading indicator + nút "Hủy" (confirm dialog)
- [ ] `VnpayPaymentResult` model — parse từ URI:
  - `vnpResponseCode`, `vnpTxnRef`, `vnpAmount`, `vnpTransactionNo`, `vnpSecureHash`
- [ ] `DeepLinkService` hoặc listener trong `app_router` — handle cold start deep link (app bị kill)

### Router
- [ ] Route `/payment/vnpay` — nhận `extra: { paymentUrl, orderId }`
- [ ] Route `/payment/result` — nhận `VnpayPaymentResult` hoặc `orderId` để verify

---

## WebView Intercept Pattern

```dart
onNavigationRequest: (request) {
  final uri = Uri.parse(request.url);
  if (uri.scheme == 'sportpro' && uri.host == 'payment-result') {
    final result = VnpayPaymentResult.fromUri(uri);
    Navigator.of(context).pop(result);
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}
```

> **Lưu ý:** Một số WebView không fire navigation cho custom scheme — test sớm trên cả Android emulator + iOS simulator. Nếu fail → dùng `flutter_inappwebview` với `shouldOverrideUrlLoading`.

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `pubspec.yaml` |
| MODIFY | `android/app/src/main/AndroidManifest.xml` |
| MODIFY | `ios/Runner/Info.plist` |
| CREATE | `lib/features/payment/domain/entities/vnpay_payment_result.dart` |
| CREATE | `lib/features/payment/presentation/pages/vnpay_payment_page.dart` |
| CREATE | `lib/features/payment/presentation/pages/payment_result_page.dart` |
| MODIFY | `lib/app/router/app_router.dart` |
| MODIFY | `lib/app/router/app_routes.dart` |

---

## Acceptance Criteria

1. Mở `paymentUrl` sandbox trong WebView — trang VNPay hiển thị
2. Simulate redirect `sportpro://payment-result?vnp_ResponseCode=00&...` → WebView đóng, app nhận params
3. Deep link hoạt động khi app ở background (warm start)
4. Nút Hủy → quay checkout, không crash
5. `flutter analyze` clean
