/// Product catalog, list, filter, and detail feature strings.
abstract final class ProductStrings {
  // Product catalog / filter
  static const String searchHint = 'Tìm kiếm sản phẩm...';
  static const String filterTitle = 'Bộ lọc';
  static const String filterClearAll = 'Xóa tất cả';
  static const String filterReset = 'Đặt lại';
  static const String filterApply = 'Áp dụng';
  static const String filterCategory = 'Danh mục';
  static const String filterBrand = 'Thương hiệu';
  static const String filterGender = 'Giới tính';
  static const String filterColor = 'Màu sắc';
  static const String filterPriceRange = 'Khoảng giá';
  static const String filterAll = 'Tất cả';
  static const String filterMale = 'Nam';
  static const String filterFemale = 'Nữ';
  static const String filterUnisex = 'Unisex';
  static const String filterMinPrice = 'Từ';
  static const String filterMaxPrice = 'Đến';
  static const String filterCurrencySuffix = 'đ';
  static const String filterUnderOneMillion = 'Dưới 1.000.000đ';
  static const String filterOneToThreeMillion = '1 - 3 triệu';
  static const String filterCategoryLoadError = 'Không tải được danh mục';
  static const String filterBrandLoadError = 'Không tải được thương hiệu';
  static const String sortNewest = 'Mới nhất';
  static const String sortPriceAsc = 'Giá tăng dần';
  static const String sortPriceDesc = 'Giá giảm dần';
  static const String catalogEmpty = 'Không tìm thấy sản phẩm';
  static const String catalogClearFilter = 'Xóa bộ lọc';
  static const String homeCategoriesTitle = 'Danh mục';
  static const String homeViewAll = 'XEM TẤT CẢ';
  static const String homeFeaturedTitle = 'Sản phẩm nổi bật';
  static const String homeFeaturedEmpty = 'Không có sản phẩm nổi bật nào.';
  static const String homeLoadError = 'Đã xảy ra lỗi khi tải trang chủ.';
  static const String homeHeroEyebrow = 'DÒNG SẢN PHẨM MỚI NHẤT';
  static const String homeHeroTitle = 'BỨT PHÁ GIỚI HẠN';
  static const String homeHeroSubtitle =
      'Trang bị đỉnh cao cho những vận động viên không ngừng vươn lên và chinh phục đỉnh cao mới.';
  static const String homeHeroCta = 'MUA SẮM NGAY';
  static const String listCollectionEyebrow = 'BỘ SƯU TẬP SPORT PRO';
  static const String listAllProducts = 'Tất cả sản phẩm';
  static const String listBack = 'Trở về';
  static const String listEmptySubtitle =
      'Không có sản phẩm nào phù hợp với bộ lọc đã chọn.';
  static const String listLoadError = 'Đã xảy ra lỗi khi tải sản phẩm.';
  static const String listFilterAndSort = 'Bộ lọc & Sắp xếp';
  static const String listSortByPrice = 'SẮP XẾP THEO GIÁ';
  static const String listSortNone = 'Không sắp xếp';
  static const String listSortPriceLowToHigh = 'Giá từ thấp đến cao';
  static const String listSortPriceHighToLow = 'Giá từ cao đến thấp';
  static const String listCategoryRunning = 'Giày chạy bộ';
  static const String listCategoryMen = 'Nam';
  static const String listCategorySize42 = 'Size 42';
  static const String listCategoryClothing = 'Quần áo';
  static String filterPriceBetween(String min, String max) => '$min - $max';
  static String filterPriceFrom(String min) => 'Từ $min';
  static String filterPriceTo(String max) => 'Đến $max';

  // Product detail — brand / rating
  static const String brandName = 'Sport Pro';
  static const String noRatingYet = 'Chưa có đánh giá';

  // Product detail — specs panel
  static const String specsTitle = 'THÔNG SỐ KỸ THUẬT';
  static const String noProductDescription = 'Sản phẩm chưa có mô tả.';

  // Product detail — reviews panel
  static const String reviewsLoadError =
      'Không thể tải đánh giá. Vui lòng thử lại sau.';
  static const String noReviewsYet = 'Sản phẩm chưa có đánh giá nào.';
  static const String anonymousReviewer = 'Khách hàng';
  static String reviewsTitle(int count) => 'ĐÁNH GIÁ KHÁCH HÀNG ($count)';
  static String reviewCount(int count) => '($count)';
  static String reviewImageCounter(int current, int total) =>
      '$current / $total';

  // Product detail — return policy panel
  static const String returnPolicyTitle = 'CHÍNH SÁCH ĐỔI TRẢ & BẢO HÀNH';
  static const String returnPolicyEmpty = 'Chưa có nội dung chính sách.';
  static const String returnPolicyLoadError =
      'Không thể tải nội dung chính sách. Vui lòng thử lại sau.';
  static const String returnPolicyLoading = 'Đang tải nội dung chính sách...';

  // Product detail — wishlist / cart feedback
  static const String addedToWishlist = 'Đã thêm vào danh sách yêu thích!';
  static const String removedFromWishlist =
      'Đã xóa khỏi danh sách yêu thích.';
  static const String detailLoadError =
      'Đã xảy ra lỗi khi tải chi tiết sản phẩm.';
  static String addedToCartMessage(String productName, String size) =>
      'Đã thêm $productName (Size $size) vào giỏ hàng!';
}
