# Phase 1: UI — Gỡ Google login

**Covers:** US-1, US-2, US-3 (P1–P2)  
**testing:** visual + analyze

## Tasks

- [x] **1.1** Xóa block `// Alternate authentication (Divider)` (Row "Hoặc").
- [x] **1.2** Xóa block `// Google Login Button` (`OutlinedButton` + SnackBar placeholder).
- [x] **1.3** Điều chỉnh `SizedBox` giữa card và footer (giữ `SizedBox(height: 32)` hoặc tương đương, bỏ 24+24 thừa từ divider/button).
- [x] **1.4** Chạy `flutter analyze` trên auth pages.

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/login_page.dart` | Remove Google UI |
| `lib/features/auth/presentation/pages/register_page.dart` | Remove Google UI |

## Done when

- Login page chỉ còn form + footer; analyze clean.
