import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryId,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
    );
  }

  static List<ProductModel> get mockList => [
        const ProductModel(
          id: 'p-001',
          name: 'AeroGlide Pro Runner X1',
          description: 'Giày chạy bộ chuyên nghiệp siêu nhẹ khí động học.',
          price: 2450000.0,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhgk4WkWkBXTRrUCXJt6iovhM2-wJzKcWFp1HBGJ2pLpBOe93MIfa1XOL3XXbHcUvA-_F6JDtc6pM4Yk8dgBWZJ4hLbRYaka6u6IAMHjJ2V9u6-0hiXYyDoYj-IVyv5B0PsvZcGg4nG520HHbRjayi4JywFFl2EM6aBawUw96VQlMYLM7fWrMPC2RwlOeugRegU1rzkI4GMgE1vtZPCB60wlUc1THtKIdvVC4NYM5yWvLydWxWuzZpnLsPvE7pcGnWdB0lYk4KQz0',
          categoryId: 'cat-running',
          stockQuantity: 50,
        ),
        const ProductModel(
          id: 'p-002',
          name: 'Phantom Speed Knit 2.0',
          description: 'Giày chạy bộ dệt kim với độ đàn hồi và tốc độ tối ưu.',
          price: 3100000.0,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAnZxEtabjD9PjXesR4AEiZFB7Wi46_Xs-9s5BN5GySN0Bs5BBVLEf_WkgEaKB01390Ld59KnH9OUuOc8GaI5BWOlXaTmPapDDdR1cUlF5hHQRKT7LhOGZClfxfEZLuQhYT7IPYNB-HwkEdI5Lkio1BlwNJCwgxunBpnTYjHpG3kbd0rfqGvcREjnZu8SfL7-RJhBRgMaUWiMSfAMXbAisJ6vQo0KXJ5ApfF7hzPn_fYfhUTmiM4g7lyQFV22VHKY9BunMDQyVp3D0',
          categoryId: 'cat-running',
          stockQuantity: 120,
        ),
        const ProductModel(
          id: 'p-003',
          name: 'Surge Momentum Blue',
          description: 'Giày chạy bộ đệm êm hỗ trợ tăng tốc mạnh mẽ.',
          price: 1955000.0,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBnCTuTyqzzPbhM9XeKm6XuKjJntekpljXO48kPP-Izz_s2x1oCYTZMPz7B30UdhhHmlkebiQVMKUvbi1TMLYgA2g5aQMxbgIOSNPXm7jB2hzB8tQm1jSEs6LsVhYDTuqbsmLJcNdFFMY8HiJa1VUi5MDJyh_Mww5TOI_hNiOXS6_xkM5CVOgdNEsgc6iBccrMSns1-QmO-DTw80BcMI0AJphR_MwTXJJ035W-P-aCTZMp01JXYKvCZgkwej-AI2w5Y17hk4-ylNhw',
          categoryId: 'cat-running',
          stockQuantity: 80,
        ),
        const ProductModel(
          id: 'p-004',
          name: 'Core Stability Trainer',
          description: 'Giày tập luyện chuyên dụng hỗ trợ giữ thăng bằng và ổn định.',
          price: 2800000.0,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA4_l--wXdihzjAfxO1aYrdnoBS-FgMGpsPCb_RNBMWlTuckoOegLdCVrIY1-buyYYfvAQz47sNqJLiEBcOw2CZCKt0fADklbhYY2SzBXBX6cbSXL6hb-QNX7ipXfu2JIu9HxX0yJGYJPVnM622L-FYX_Hg4_RVIUj5ubTwoq92BkQaPg8UOoquKKa_W8P45IQtJYyhO8ZgSExbg-LpQUayfkhS9cAbbZMuZC7sqMflDt_DoBHV-T1geWJjKlQd0bS2Vyn8q9XHPj0',
          categoryId: 'cat-training',
          stockQuantity: 95,
        ),
      ];
}
