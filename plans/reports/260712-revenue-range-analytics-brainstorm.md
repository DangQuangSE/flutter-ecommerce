# Brainstorm: Revenue analytics by custom date range

**Date:** 2026-07-12

## Ideas Explored

- Doanh thu theo ngày tạo đơn: dễ query nhưng sai bản chất vì đơn có thể chưa thanh toán hoặc bị hủy.
- Doanh thu ngay khi VNPay thành công: phản ánh dòng tiền vào nhưng chưa xử lý rủi ro giao thất bại/hoàn tiền.
- Doanh thu khi giao thành công: gần mô hình Shopee Guarantee nhưng cần đảm bảo trạng thái thanh toán nhất quán.
- Doanh thu thực nhận: chỉ ghi nhận đơn vừa thanh toán vừa giao, theo `deliveredAt`; đơn hoàn tiền bị loại khỏi doanh thu ròng.
- Preset tuần/tháng/năm: tiện nhưng không đủ cho đối soát; lựa chọn cuối là khoảng ngày tùy chỉnh kèm preset nhanh.

## User's Direction

Áp dụng mô hình doanh thu thực nhận tương tự Shopee: `paymentCompleted = true` và `status = DELIVERED`, lọc theo khoảng thời gian admin chọn. Flutter cung cấp preset nhanh và date-range picker.

## Open Questions

- Không còn blocker. Chi tiết biểu đồ có thể nhóm tự động theo độ dài khoảng thời gian.

## Risks

- Order hiện chưa có `deliveredAt`; dùng `createdAt` sẽ tiếp tục cho kết quả sai.
- Đơn VNPay #1 đang `DELIVERED` nhưng `paymentCompleted = false`, cho thấy payment/status flow và dữ liệu cũ cần migration.
- Dashboard Flutter hiện không tự refresh sau cập nhật trạng thái đơn.

