part of 'color_management_page.dart';

extension _ColorManagementPrintingForm on _ColorManagementPageState {
  void _openPrintingColorForm(BuildContext context,
      {PrintingColorEntity? color}) {
    final bool isEdit = color != null;
    final nameController = TextEditingController(text: color?.name ?? '');
    final hexController = TextEditingController(text: color?.hexCode ?? '#');
    bool activeVal = color?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Sửa màu in ấn' : 'Thêm màu in ấn mới',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Name
                    _buildLabel('TÊN MÀU IN'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên màu in (ví dụ: Gold Foil)',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hex Code
                    _buildLabel('MÃ HEX (HEX CODE)'),
                    TextField(
                      controller: hexController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Nhập mã Hex (ví dụ: #D4AF37)',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.color_lens_outlined,
                              color: AppColors.primary),
                          onPressed: () => _openColorPickerDialog(
                              context, hexController, setSheetState),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Color Preview
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _hexToColor(hexController.text),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Xem trước màu sắc',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Presets
                    _buildLabel('MÀU ĐÃ CÓ SẴN (GỢI Ý)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((preset) {
                        final parsedPresetColor = _hexToColor(preset['hex']!);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              nameController.text = preset['name']!;
                              hexController.text = preset['hex']!;
                            });
                          },
                          child: Chip(
                            backgroundColor:
                                parsedPresetColor.withValues(alpha: 0.12),
                            side: BorderSide(
                                color:
                                    parsedPresetColor.withValues(alpha: 0.3)),
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor: parsedPresetColor,
                            ),
                            label: Text(
                              preset['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('TRẠNG THÁI HOẠT ĐỘNG'),
                        Switch.adaptive(
                          value: activeVal,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setSheetState(() {
                              activeVal = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final hex = hexController.text.trim().toUpperCase();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Vui lòng nhập tên màu in!'),
                                backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        final regex =
                            RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
                        if (!regex.hasMatch(hex)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mã HEX không hợp lệ!'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        final colorEntity = PrintingColorEntity(
                          id: color?.id,
                          name: name,
                          hexCode: hex,
                          isActive: activeVal,
                        );

                        if (isEdit) {
                          context
                              .read<PrintingColorCubit>()
                              .updateColor(color.id!, colorEntity);
                        } else {
                          context
                              .read<PrintingColorCubit>()
                              .createColor(colorEntity);
                        }

                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'LƯU THAY ĐỔI' : 'THÊM MÀU IN ẤN',
                        style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
