# .anti-flutter — Bộ Quy Tắc & Skill cho Antigravity AI Agent

Bộ này giúp Antigravity AI agent luôn generate Flutter code đúng theo kiến trúc Clean Architecture của project. Bao gồm hai phần: **rules nền** (luôn active) và **skills** (gọi khi cần).

---

## Cách thiết lập

### Bước 1 — Đăng ký RULES.md với Antigravity

Truy cập cài đặt của Antigravity → phần "Project Rules" hoặc "Context Files", thêm đường dẫn:

```
.anti-flutter/RULES.md
```

Sau đó mỗi lần generate code trong project này, agent sẽ tự đọc file đó và follow đúng convention mà không cần nhắc lại.

### Bước 2 — Đăng ký Skills

Trong cài đặt Antigravity → phần "Skills" hoặc "Custom Commands", đăng ký 4 skills:

| Tên skill | Đường dẫn file |
|-----------|---------------|
| `add-feature` | `.anti-flutter/skills/add-feature/SKILL.md` |
| `add-bloc` | `.anti-flutter/skills/add-bloc/SKILL.md` |
| `fix-arch` | `.anti-flutter/skills/fix-arch/SKILL.md` |
| `wire-di` | `.anti-flutter/skills/wire-di/SKILL.md` |

---

## Cách sử dụng hàng ngày

### Rules nền — không cần làm gì thêm

Sau khi thiết lập xong, `RULES.md` được đọc tự động. Agent sẽ tự biết:
- Tạo file đúng thư mục (`lib/features/{feature}/data|domain|presentation/`)
- Không gọi API thẳng từ widget
- Dùng `sealed class` cho BLoC state
- Dùng `Result<T>` thay vì throw exception

---

### `/add-feature` — Tạo feature mới từ đầu

Dùng khi muốn scaffold một feature e-commerce mới đầy đủ 3 layer.

**Cú pháp:**
```
/add-feature wishlist
/add-feature notification
/add-feature review
```

**Agent sẽ tạo:**
```
lib/features/wishlist/
  data/
    datasources/wishlist_remote_datasource.dart
    datasources/wishlist_remote_datasource_impl.dart
    models/wishlist_model.dart
    repositories/wishlist_repository_impl.dart
  domain/
    entities/wishlist_entity.dart
    repositories/wishlist_repository.dart
    usecases/get_wishlists_usecase.dart
  presentation/
    bloc/wishlist_bloc.dart
    bloc/wishlist_event.dart
    bloc/wishlist_state.dart
    pages/wishlist_page.dart
    widgets/
```

**Ví dụ prompt:**
```
/add-feature wishlist

Feature name: wishlist
Entity fields: id, userId, productId, addedAt (DateTime)
State type: BLoC (nhiều event)
```

---

### `/add-bloc` — Thêm BLoC hoặc Cubit vào feature đã có

Dùng khi feature đã có domain/data layer nhưng chưa có state management, hoặc cần thêm BLoC riêng.

**Cú pháp:**
```
/add-bloc product
/add-cubit cart
/add-bloc checkout
```

**Agent sẽ tạo** (ví dụ với wishlist):
```dart
// wishlist_event.dart — sealed class với Equatable
// wishlist_state.dart — WishlistInitial, WishlistLoading, WishlistLoaded, WishlistError
// wishlist_bloc.dart  — handlers dùng Result<T>, switch không có default
```

**Khi nào dùng BLoC, khi nào dùng Cubit:**

| BLoC | Cubit |
|------|-------|
| `auth`, `product`, `checkout`, `order` | `cart`, `profile`, UI toggles |
| Nhiều event từ nhiều chỗ | State đơn giản, ít transition |

---

### `/fix-arch` — Kiểm tra và sửa vi phạm kiến trúc

Dùng sau khi agent generate code tự do, hoặc khi muốn kiểm tra một feature có đúng chuẩn không.

**Cú pháp:**
```
/fix-arch product
/fix-arch auth
/fix-arch cart
```

**Agent sẽ kiểm tra và báo cáo:**
```
## Architecture Audit: product

### CRITICAL
- [ ] product_list_page.dart:45 — Calls dio.get() directly in widget
        Fix: Move to ProductRemoteDataSourceImpl, call via repository → use case → BLoC

### HIGH
- [ ] product_bloc.dart:23 — Uses 'default:' arm on sealed ProductState
        Fix: Replace with explicit case ProductInitial(): case ProductLoading():

### PASS
- ✓ Layer imports correct
- ✓ Entity has no fromJson
- ✓ Repository is abstract interface only
```

---

### `/wire-di` — Đăng ký DI sau khi tạo feature

Dùng sau `/add-feature` để đăng ký toàn bộ components vào `injection_container.dart`.

**Cú pháp:**
```
/wire-di wishlist
/wire-di notification
```

**Agent sẽ thêm vào `injection_container.dart`:**
```dart
// Wishlist
sl.registerLazySingleton<WishlistRemoteDataSource>(
  () => WishlistRemoteDataSourceImpl(sl<DioClient>()),
);
sl.registerLazySingleton<WishlistRepository>(
  () => WishlistRepositoryImpl(sl<WishlistRemoteDataSource>()),
);
sl.registerLazySingleton<GetWishlistsUseCase>(
  () => GetWishlistsUseCase(sl<WishlistRepository>()),
);
sl.registerFactory<WishlistBloc>(      // ← registerFactory, KHÔNG phải Singleton
  () => WishlistBloc(getUseCase: sl()),
);
```

---

## Workflow điển hình khi thêm feature mới

```
1. /add-feature wishlist          → tạo toàn bộ 3-layer structure
2. /add-bloc wishlist             → tạo BLoC với sealed states (nếu chưa có)
3. /wire-di wishlist              → đăng ký vào injection_container.dart
4. Viết UI thực tế trong         → lib/features/wishlist/presentation/pages/
5. /fix-arch wishlist             → kiểm tra lại nếu cần
```

---

## Tài liệu tham khảo

Các file trong `.anti-flutter/references/` chứa code mẫu thực tế từ codebase:

| File | Nội dung |
|------|----------|
| [folder-structure.md](references/folder-structure.md) | Toàn bộ cây thư mục `lib/` |
| [bloc-patterns.md](references/bloc-patterns.md) | AuthBloc, CartCubit, cách dùng trong page |
| [di-patterns.md](references/di-patterns.md) | Toàn bộ `injection_container.dart`, bảng factory vs singleton |
| [result-patterns.md](references/result-patterns.md) | Result`<T>`, Success, ResultFailure, Failure types |

---

## Những lỗi phổ biến agent hay mắc (và cách phát hiện)

| Lỗi | Dấu hiệu | Cách fix |
|-----|----------|----------|
| Gọi API trong widget | `dio.get()` trong file `_page.dart` | `/fix-arch {feature}` |
| BLoC dùng abstract thay sealed | `abstract class ProductState` | Đổi thành `sealed class` |
| Switch có `default:` | `default: break;` trong switch state | Thêm explicit cases |
| BLoC đăng ký sai | `registerLazySingleton<ProductBloc>` | Đổi thành `registerFactory` |
| Entity có `fromJson` | `factory ProductEntity.fromJson` | Chuyển sang `ProductModel` |
| `context.read()` trong `initState` | Lỗi async gap warning | Bọc trong `Future.microtask` |
