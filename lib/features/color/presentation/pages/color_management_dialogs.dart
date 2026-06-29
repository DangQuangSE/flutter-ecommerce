part of 'color_management_page.dart';

extension _ColorManagementDialogs on _ColorManagementPageState {
  void _openColorPickerDialog(
    BuildContext context,
    TextEditingController hexController,
    StateSetter setSheetState,
  ) {
    Color initColor = _hexToColor(hexController.text);
    showDialog(
      context: context,
      builder: (diagContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Chọn màu sắc',
            style:
                GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initColor,
              onColorChanged: (color) {
                final hexStr =
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                hexController.text = hexStr;
                setSheetState(() {});
              },
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagContext),
              child: Text(
                'XONG',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _confirmDeleteProductColor(
      BuildContext context, ProductColorEntity color) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa màu sản phẩm?',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content:
            Text('Bạn có chắc muốn xóa màu "${color.name}" khỏi sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text('HỦY',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (color.id != null) {
                context.read<ProductColorCubit>().deleteColor(color.id!);
              }
              Navigator.pop(diagContext);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePrintingColor(
      BuildContext context, PrintingColorEntity color) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa màu in ấn?',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xóa màu in ấn "${color.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text('HỦY',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (color.id != null) {
                context.read<PrintingColorCubit>().deleteColor(color.id!);
              }
              Navigator.pop(diagContext);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }
}
