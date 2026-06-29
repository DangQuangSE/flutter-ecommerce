part of 'product_list_page.dart';

extension _ProductListContent on _ProductListPageState {
  Widget _buildScrollView(
      double statusBarHeight, List<ProductEntity> products) {
    // Symmetrical column listings
    final List<ProductEntity> col1 = [];
    final List<ProductEntity> col2 = [];

    for (int i = 0; i < products.length; i++) {
      if (i % 2 == 0) {
        col1.add(products[i]);
      } else {
        col2.add(products[i]);
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 92, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant category header label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'BỘ SƯU TẬP SPORT PRO',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              _selectedCategory == 'Tất cả'
                  ? 'Tất cả sản phẩm'
                  : _selectedCategory,
              style: GoogleFonts.lexend(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.6,
              ),
            ),
          ),

          // 2. Filter & Category pills row
          _buildActionAndFilterRow(context),
          const SizedBox(height: 16),

          if (products.isEmpty) ...[
            _buildEmptyState()
          ] else ...[
            // 3. Fully symmetrical dual-column layout (no staggering offsets)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(col1.length, (index) {
                      final product = col1[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProductTactileCard(
                          product: product,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: List.generate(col2.length, (index) {
                      final product = col2[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProductTactileCard(
                          product: product,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionAndFilterRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.home);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Trở về',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showFilterSheet(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedSort == 'Không sắp xếp'
                          ? 'Bộ lọc'
                          : _selectedSort,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Custom choice chip Row
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    _selectCategory(category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.textPrimary
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Không có sản phẩm nào phù hợp với bộ lọc đã chọn.',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
