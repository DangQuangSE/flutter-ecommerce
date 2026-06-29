import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/models/coupon_form_extra.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_state.dart';

class CouponManagementPage extends StatefulWidget {
  const CouponManagementPage({super.key});

  @override
  State<CouponManagementPage> createState() => _CouponManagementPageState();
}

class _CouponManagementPageState extends State<CouponManagementPage> {
  final _searchController = TextEditingController();
  final _amountFormat = NumberFormat.decimalPattern('vi_VN');

  /// Client-side filter — the backend list endpoint has no search parameter.
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CouponCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CouponCubit get _cubit => context.read<CouponCubit>();

  void _openForm({CouponEntity? coupon}) {
    context.pushNamed(
      AppRoutes.adminCouponForm,
      extra: CouponFormExtra(
        cubit: _cubit,
        coupon: coupon,
      ),
    );
  }

  Future<void> _confirmDelete(CouponEntity coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xoá mã giảm giá',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xoá mã "${coupon.code}"?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || coupon.id == null) return;
    final error = await _cubit.delete(coupon.id!);
    if (!mounted) return;
    _showSnack(error ?? 'Đã xoá mã giảm giá', isError: error != null);
  }

  Future<void> _toggle(CouponEntity coupon) async {
    final error = await _cubit.toggleStatus(coupon, isActive: !coupon.isActive);
    if (!mounted) return;
    if (error != null) _showSnack(error, isError: true);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ));
  }

  /// Human-readable discount, e.g. `20%` or `50.000đ`.
  String _discountText(CouponEntity c) {
    if (c.discountType == DiscountType.percentage) {
      final v = c.discountValue;
      final whole = v == v.roundToDouble() ? v.toInt().toString() : '$v';
      return '$whole%';
    }
    return '${_amountFormat.format(c.discountValue)}đ';
  }

  String _dateText(DateTime? d) =>
      d == null ? '—' : DateFormat('dd/MM/yyyy HH:mm').format(d);

  // ── Detail bottom sheet ─────────────────────────────────────────────────────
  void _showDetail(CouponEntity c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _detailContent(c),
    );
  }

  Widget _detailContent(CouponEntity c) {
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary)),
              ),
            ],
          ),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(c.code,
                style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            row('Loại giảm', c.discountType.label),
            row('Giá trị giảm', _discountText(c)),
            row(
                'Đơn tối thiểu',
                c.minOrderAmount == null
                    ? '—'
                    : '${_amountFormat.format(c.minOrderAmount)}đ'),
            row(
                'Giảm tối đa',
                c.maxDiscountAmount == null
                    ? '—'
                    : '${_amountFormat.format(c.maxDiscountAmount)}đ'),
            row('Hạng yêu cầu', c.requiredTier?.label ?? 'Không yêu cầu'),
            row('Bắt đầu', _dateText(c.startDate)),
            row('Kết thúc', _dateText(c.endDate)),
            row('Giới hạn dùng', c.usageLimit?.toString() ?? 'Không giới hạn'),
            row('Đã dùng', c.usedCount.toString()),
            row('Trạng thái', c.isActive ? 'Đang hoạt động' : 'Tạm tắt'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Quản lý mã giảm giá',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text('Thêm',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<CouponCubit, CouponState>(
              builder: (context, state) {
                if (state is CouponLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }
                if (state is CouponError) {
                  return _buildError(state.message);
                }
                if (state is CouponLoaded) {
                  final filtered = _query.isEmpty
                      ? state.coupons
                      : state.coupons
                          .where((c) => c.code
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                          .toList();
                  if (state.coupons.isEmpty) return _buildEmpty();
                  return _buildList(state, filtered);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        decoration: InputDecoration(
          hintText: 'Tìm theo mã giảm giá...',
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildList(CouponLoaded state, List<CouponEntity> filtered) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _cubit.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        // When a search filters everything out, reserve a second slot (index 1)
        // for the "no matches" message — otherwise the header consumes the only
        // slot and the message is unreachable.
        itemCount: filtered.isEmpty ? 2 : filtered.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _query.isEmpty
                        ? '${state.totalElements} mã giảm giá'
                        : '${filtered.length}/${state.coupons.length} mã',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (state.isMutating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                ],
              ),
            );
          }
          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text('Không có mã nào khớp "$_query".',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
              ),
            );
          }
          return _buildTile(filtered[index - 1]);
        },
      ),
    );
  }

  Widget _buildTile(CouponEntity coupon) {
    final inactive = !coupon.isActive || coupon.isExpired || coupon.isUsedUp;
    return GestureDetector(
      onTap: () => _showDetail(coupon),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (inactive ? AppColors.textSecondary : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_offer_rounded,
                  color:
                      inactive ? AppColors.textSecondary : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coupon.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _discountChip(coupon),
                    ],
                  ),
                  const SizedBox(height: 3),
                  _subtitle(coupon),
                ],
              ),
            ),
            Switch.adaptive(
              value: coupon.isActive,
              activeThumbColor: AppColors.success,
              onChanged: (_) => _toggle(coupon),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') _openForm(coupon: coupon);
                if (value == 'delete') _confirmDelete(coupon);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xoá')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _discountChip(CouponEntity c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '-${_discountText(c)}',
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _subtitle(CouponEntity c) {
    final parts = <String>[];
    if (c.usageLimit != null) {
      parts.add('Đã dùng ${c.usedCount}/${c.usageLimit}');
    } else {
      parts.add('Đã dùng ${c.usedCount}');
    }
    if (c.endDate != null) {
      parts.add('HSD ${DateFormat('dd/MM/yyyy').format(c.endDate!)}');
    }
    String tag = '';
    Color tagColor = AppColors.textSecondary;
    if (c.isExpired) {
      tag = 'Hết hạn';
      tagColor = AppColors.error;
    } else if (c.isUsedUp) {
      tag = 'Hết lượt';
      tagColor = AppColors.warning;
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        if (tag.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag,
                style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700, color: tagColor)),
          ),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Chưa có mã giảm giá nào',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nhấn "Thêm" để tạo mã đầu tiên.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Không tải được mã giảm giá',
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _cubit.load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
