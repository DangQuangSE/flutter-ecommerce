import 'package:geolocator/geolocator.dart';

import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// Wraps `geolocator` for the "current position" flow: checks the location
/// service is on and permission is granted, then returns a [GeoPoint].
/// Maps each failure mode to a [LocationFailure] so the UI can react
/// (e.g. offer "open settings" when permission is permanently denied).
class DeviceLocationService {
  const DeviceLocationService();

  Future<Result<GeoPoint>> currentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const ResultFailure(
          LocationFailure('Dịch vụ vị trí đang tắt. Vui lòng bật GPS.'),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const ResultFailure(
          LocationFailure(
            'Quyền vị trí đã bị từ chối. Mở cài đặt để cấp quyền.',
            permanentlyDenied: true,
          ),
        );
      }
      if (permission == LocationPermission.denied) {
        return const ResultFailure(
          LocationFailure('Bạn cần cấp quyền vị trí để chỉ đường.'),
        );
      }

      final position = await Geolocator.getCurrentPosition();
      return Success(
        GeoPoint(latitude: position.latitude, longitude: position.longitude),
      );
    } catch (_) {
      return const ResultFailure(
        LocationFailure('Không thể lấy vị trí hiện tại.'),
      );
    }
  }

  /// Opens the OS app-settings page so the user can grant a denied permission.
  Future<void> openSettings() => Geolocator.openAppSettings();
}
