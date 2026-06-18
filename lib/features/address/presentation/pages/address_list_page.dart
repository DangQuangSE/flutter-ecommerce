import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/address/presentation/pages/address_form_page.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_card.dart';
import 'package:google_fonts/google_fonts.dart';

/// When [pickerMode] is true the page returns the tapped [AddressEntity] via
/// Navigator.pop instead of showing edit actions.
class AddressListPage extends StatefulWidget {
 const AddressListPage({super.key, this.pickerMode = false});

 final bool pickerMode;

 @override
 State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 backgroundColor: AppColors.background,
 appBar: AppBar(
 backgroundColor: Colors.white,
 foregroundColor: AppColors.textPrimary,
 elevation: 0,
 automaticallyImplyLeading: false,
 leading: IconButton(
 icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
 onPressed: () => Navigator.of(context).pop(),
 ),
 title: Text(
 widget.pickerMode ? 'Chọn địa chỉ giao hàng' : 'Địa chỉ giao hàng',
 style: GoogleFonts.plusJakartaSans(
 fontSize: AppSizes.fontXxl,
 fontWeight: FontWeight.w700,
 color: AppColors.textPrimary,
 ),
 ),
 actions: [
 if (!widget.pickerMode)
 TextButton.icon(
 onPressed: () => _openForm(context, null),
 icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
 label: Text(
 'Thêm',
 style: GoogleFonts.plusJakartaSans(
 fontWeight: FontWeight.w700,
 color: AppColors.primary,
 ),
 ),
 ),
 ],
 ),
 body: BlocConsumer<AddressCubit, AddressState>(
 listener: (context, state) {
 if (state is AddressError) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(state.message)),
 );
 }
 },
 builder: (context, state) => switch (state) {
 AddressLoading() => const Center(child: CircularProgressIndicator()),
 AddressInitial() => const Center(child: CircularProgressIndicator()),
 AddressLoaded(:final addresses) ||
 AddressActionSuccess(:final addresses) =>
 _AddressList(
 addresses: addresses,
 pickerMode: widget.pickerMode,
 onEdit: (a) => _openForm(context, a),
 onDelete: (a) => _confirmDelete(context, a),
 onSetDefault: (a) =>
 context.read<AddressCubit>().setDefault(a.id!),
 onSelect: (a) => Navigator.of(context).pop(a),
 ),
 AddressError() => _EmptyState(
 onAdd: () => _openForm(context, null),
 ),
 },
 ),
 bottomNavigationBar: SafeArea(
 child: Padding(
 padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
 child: ElevatedButton.icon(
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.primary,
 minimumSize:
 const Size(double.infinity, AppSizes.buttonMinHeight),
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(AppSizes.radiusLg),
 ),
 ),
 icon: const Icon(Icons.add, color: Colors.white),
 label: Text(
 'Thêm địa chỉ mới',
 style: GoogleFonts.plusJakartaSans(
 fontWeight: FontWeight.w700,
 color: Colors.white,
 ),
 ),
 onPressed: () => _openForm(context, null),
 ),
 ),
 ),
 );
 }

 Future<void> _openForm(BuildContext context, AddressEntity? initial) async {
 final cubit = context.read<AddressCubit>();
 await Navigator.of(context).push<void>(
 MaterialPageRoute(
 builder: (_) => BlocProvider.value(
 value: cubit,
 child: AddressFormPage(initial: initial),
 ),
 ),
 );
 }

 Future<void> _confirmDelete(
 BuildContext context,
 AddressEntity address,
 ) async {
 final confirmed = await showDialog<bool>(
 context: context,
 builder: (ctx) => AlertDialog(
 title: Text(
 'Xóa địa chỉ',
 style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
 ),
 content: Text(
 'Bạn có chắc muốn xóa địa chỉ này?',
 style: GoogleFonts.plusJakartaSans(fontSize: AppSizes.fontLg),
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(ctx).pop(false),
 child: Text(
 'Hủy',
 style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
 ),
 ),
 TextButton(
 onPressed: () => Navigator.of(ctx).pop(true),
 child: Text(
 'Xóa',
 style: GoogleFonts.plusJakartaSans(
 fontWeight: FontWeight.w700,
 color: AppColors.error,
 ),
 ),
 ),
 ],
 ),
 );

 if (confirmed == true && context.mounted) {
 context.read<AddressCubit>().deleteAddress(address.id!);
 }
 }
}

class _AddressList extends StatelessWidget {
 const _AddressList({
 required this.addresses,
 required this.pickerMode,
 required this.onEdit,
 required this.onDelete,
 required this.onSetDefault,
 required this.onSelect,
 });

 final List<AddressEntity> addresses;
 final bool pickerMode;
 final void Function(AddressEntity) onEdit;
 final void Function(AddressEntity) onDelete;
 final void Function(AddressEntity) onSetDefault;
 final void Function(AddressEntity) onSelect;

 @override
 Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return _EmptyState(
        onAdd: () => onEdit(const AddressEntity(
          fullName: '',
          phoneNumber: '',
          addressLine: '',
          ward: '',
          district: '',
          city: '',
        )),
      );
    }

 return ListView.separated(
 padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
 itemCount: addresses.length,
 separatorBuilder: (_, __) => AppSizes.spacingMd,
 itemBuilder: (_, index) {
 final address = addresses[index];
 return AddressCard(
 address: address,
 selectable: pickerMode,
 selected: pickerMode && address.isDefault,
 onTap: pickerMode ? () => onSelect(address) : null,
 onEdit: () => onEdit(address),
 onDelete: () => onDelete(address),
 onSetDefault: () => onSetDefault(address),
 );
 },
 );
 }
}

class _EmptyState extends StatelessWidget {
 const _EmptyState({this.onAdd});

 final VoidCallback? onAdd;

 @override
 Widget build(BuildContext context) {
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.location_off_outlined,
 size: 56,
 color: AppColors.textSecondary.withValues(alpha: 0.4),
 ),
 AppSizes.spacingMd,
 Text(
 'Chưa có địa chỉ nào',
 style: GoogleFonts.plusJakartaSans(
 fontSize: AppSizes.fontXl,
 fontWeight: FontWeight.w600,
 color: AppColors.textSecondary,
 ),
 ),
 if (onAdd != null) ...[
 AppSizes.spacingMd,
 ElevatedButton(
 onPressed: onAdd,
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.primary,
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(AppSizes.radiusLg),
 ),
 ),
 child: Text(
 'Thêm địa chỉ',
 style: GoogleFonts.plusJakartaSans(
 fontWeight: FontWeight.w700,
 color: Colors.white,
 ),
 ),
 ),
 ],
 ],
 ),
 );
 }
}
