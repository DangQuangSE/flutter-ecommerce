import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ChatListFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const ChatListFilters({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChatSearchBar(
          controller: searchController,
          searchQuery: searchQuery,
          onChanged: onSearchChanged,
          onClear: () {
            searchController.clear();
            onSearchChanged('');
          },
        ),
        _ChatFilterChips(
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
      ],
    );
  }
}

class _ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ChatSearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingMd,
          AppSizes.spacing12, AppSizes.paddingMd, AppSizes.paddingSm),
      child: TextField(
        controller: controller,
        onChanged: (value) => onChanged(value.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: AppStrings.chatSearchHint,
          hintStyle: GoogleFonts.inter(
            fontSize: AppSizes.font13,
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: AppSizes.iconMd,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: AppSizes.iconMd18,
                  ),
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : AppColors.canvasLight,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 0, horizontal: AppSizes.paddingMd),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _ChatFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _ChatFilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingMd, AppSizes.paddingXs,
          AppSizes.paddingMd, AppSizes.spacing12),
      child: Row(
        children: [
          _ChatFilterChip(
            label: AppStrings.chatFilterAll,
            filterValue: 'all',
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          SizedBox(width: AppSizes.paddingSm),
          _ChatFilterChip(
            label: AppStrings.chatFilterUnread,
            filterValue: 'unread',
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          SizedBox(width: AppSizes.paddingSm),
          _ChatFilterChip(
            label: AppStrings.chatFilterSupport,
            filterValue: 'support',
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}

class _ChatFilterChip extends StatelessWidget {
  final String label;
  final String filterValue;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _ChatFilterChip({
    required this.label,
    required this.filterValue,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedFilter == filterValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onFilterChanged(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.primary 
              : (isDark ? const Color(0xFF1E293B) : AppColors.canvasLight),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            color: isActive 
                ? Colors.white 
                : (isDark ? Colors.white70 : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

