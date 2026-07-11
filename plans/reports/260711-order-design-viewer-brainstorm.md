# Brainstorm: Read-only order design viewer

**Date:** 2026-07-11

## Ideas Explored

- Chỉ phóng lớn ảnh preview trong popup: nhanh nhưng không cho admin kiểm tra từng layer.
- Màn hình toàn màn hình giống customizer: cho phép đổi mặt trước/sau, zoom và chọn layer mà không chỉnh sửa.
- Dùng lại nguyên customizer rồi khóa nút lưu: rủi ro vẫn để lộ thao tác kéo, xóa và resize; cần chế độ `readOnly` rõ ràng.
- Upload và lưu riêng từng logo: giải quyết việc xem file logo gốc trên thiết bị khác, nhưng được hoãn sang giai đoạn sau.
- Admin tải preview: phù hợp MVP bằng cách mở URL ảnh mặt trước/sau; lưu trực tiếp vào thư viện thiết bị có thể bổ sung sau.

## User's Direction

Ưu tiên làm viewer trước. Viewer phải giống customizer ở chế độ chỉ xem, cho phép user và admin xem tất cả thành phần đã lưu. Admin có thêm thao tác mở/tải preview; chưa sửa quy trình upload logo trong giai đoạn này.

## Open Questions

- Cơ chế lưu/tải file logo gốc sẽ được thiết kế trong phase sau.
- Việc tải trực tiếp vào thư viện ảnh hay chỉ mở URL preview sẽ được đánh giá sau MVP.

## Risks

- `logoPath` của thiết kế cũ là đường dẫn cục bộ nên admin không thể dựng lại file logo riêng; preview thành phẩm vẫn sử dụng được.
- Metadata cũ hoặc malformed phải fallback sang preview, không được làm crash viewer.
- Canvas hiện có hỗ trợ chỉnh sửa; chế độ chỉ đọc phải khóa toàn bộ mutation và ẩn handle.

