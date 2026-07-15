/// Review feature strings (write review, parse errors).
abstract final class ReviewStrings {
  static const String writeTitle = 'Đánh giá sản phẩm';
  static const String ratingLabel = 'Bạn đánh giá sản phẩm này bao nhiêu sao?';
  static const String commentLabel = 'Nhận xét của bạn';
  static const String commentHint = 'Chia sẻ cảm nhận của bạn về sản phẩm...';
  static const String addImage = 'Thêm ảnh';
  static const String submit = 'Gửi đánh giá';
  static const String ratingRequired = 'Vui lòng chọn số sao';
  static const String commentRequired = 'Vui lòng nhập nhận xét';
  static const String submitSuccess = 'Đã gửi đánh giá. Cảm ơn bạn!';
  static const String submitError = 'Lỗi gửi đánh giá';
  static const String listParseError = 'Phản hồi danh sách đánh giá không hợp lệ';
  static const String parseError = 'Phản hồi đánh giá không hợp lệ';
  static const String writeParseError = 'Phản hồi gửi đánh giá không hợp lệ';
  static String maxImages(int max) => 'Chỉ được chọn tối đa $max ảnh';
}
