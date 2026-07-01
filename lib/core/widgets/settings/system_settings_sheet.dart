import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/app/theme/theme_cubit.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/storage/app_settings_storage.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

/// Reusable bottom sheet for system settings (notification sound + theme mode).
/// Used by both user profile and admin profile.
class SystemSettingsSheet extends StatefulWidget {
  const SystemSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SystemSettingsSheet(),
    );
  }

  @override
  State<SystemSettingsSheet> createState() => _SystemSettingsSheetState();
}

class _SystemSettingsSheetState extends State<SystemSettingsSheet> {
  late final AppSettingsStorage _settingsStorage;
  late bool _notificationSoundEnabled;

  @override
  void initState() {
    super.initState();
    _settingsStorage = AppSettingsStorage(sl<LocalStorage>());
    _notificationSoundEnabled =
        _settingsStorage.isNotificationSoundEnabled;
  }

  Future<void> _setNotificationSoundEnabled(bool value) async {
    setState(() => _notificationSoundEnabled = value);
    await _settingsStorage.setNotificationSoundEnabled(value: value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.systemSettingsTitle,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.volume_up_outlined,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                AppStrings.notificationSoundTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                AppStrings.notificationSoundSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
              value: _notificationSoundEnabled,
              onChanged: _setNotificationSoundEnabled,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dark_mode_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      AppStrings.systemSettingsThemeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, currentMode) {
                    return DropdownButton<ThemeMode>(
                      value: currentMode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(AppStrings.systemSettingsThemeSystem),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(AppStrings.systemSettingsThemeLight),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(AppStrings.systemSettingsThemeDark),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          context.read<ThemeCubit>().updateThemeMode(mode);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
