part of 'home_page.dart';

extension _HomeContent on _HomePageState {
  Widget _buildContent(BuildContext context, List<ProductEntity> products,
      double statusBarHeight) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, statusBarHeight + 92, 0, 120),
      children: [
        // 1. Hero Section (Nested Double-Bezel & Button-in-Button CTA)
        _buildHeroSection(context),

        // 2. Categories Snap Horizontal Scroll Section (Glassmorphic)
        _buildCategoriesSection(context),

        // 3. Featured Products Grid Section (Asymmetric Bento)
        _buildFeaturedProducts(context, products),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Danh mục',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.productList),
                  child: Text(
                    'XEM TẤT CẢ',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Category horizontal gallery
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.productList),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Image.network(
                          cat['image']!,
                          fit: BoxFit.cover,
                        ),
                        // Soft overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black12,
                              ],
                            ),
                          ),
                        ),
                        // Title text
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            cat['title']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(
      BuildContext context, List<ProductEntity> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sản phẩm nổi bật',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Không có sản phẩm nổi bật nào.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final featuredList = products.take(4).toList();
    final List<Widget> rows = [];

    for (int i = 0; i < featuredList.length; i += 2) {
      final item1 = featuredList[i];
      final item2 = (i + 1 < featuredList.length) ? featuredList[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProductTactileCard(product: item1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: item2 != null
                  ? ProductTactileCard(product: item2)
                  : const SizedBox(),
            ),
          ],
        ),
      );

      if (i + 2 < featuredList.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sản phẩm nổi bật',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),
          ...rows,
        ],
      ),
    );
  }

  // Shared Navigation component hooks are utilized dynamically
}
