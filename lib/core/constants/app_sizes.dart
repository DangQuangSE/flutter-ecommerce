import 'package:flutter/widgets.dart';

abstract final class AppSizes {
  // Padding
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 20.0;
  static const double paddingXl = 24.0;

  // Radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusRound = 20.0;

  // Font sizes
  static const double fontXxs = 7.0;
  static const double fontBadge = 8.0;
  static const double fontXs = 9.0;
  static const double fontSm = 11.0;
  static const double fontMd = 12.0;
  static const double fontLg = 14.0;
  static const double fontXl = 16.0;
  static const double fontXxl = 18.0;
  static const double fontHeading = 22.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 28.0;
  static const double iconXxl = 48.0;

  // Canvas
  static const double canvasWidthRatio = 0.85;
  static const double canvasHeightRatio = 0.42;
  static const double canvasMaxOffsetRatio = 0.40;
  static const double bottomSheetMaxHeightRatio = 0.75;
  static const double canvasMinZoom = 0.7;
  static const double canvasMaxZoom = 1.6;
  static const double canvasZoomStep = 0.1;

  // Color picker
  static const double colorSwatchSize = 36.0;

  // Shop profile
  static const double shopCoverRatio =
      0.42; // cover height = screenWidth * ratio
  static const double shopLogoSize = 80.0;
  static const double iconXl = 64.0;
  static const double fontDisplay = 32.0;
  static const double borderThick = 3.0;
  static const double letterSpacingWide = 1.0;

  // Extra spacing
  static const double spacing6 = 6.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;

  // Extra icon sizes
  static const double iconMd18 = 18.0;
  static const double iconNav = 22.0;
  static const double iconNavActive = 24.0;

  // Extra radius
  static const double radius8 = 8.0;
  static const double radius14 = 14.0;
  static const double radiusFull = 30.0;

  // Extra font sizes
  static const double font13 = 13.0;
  static const double fontTitle = 26.0;

  // Others
  static const double buttonMinHeight = 44.0;
  static const double tabVerticalPadding = 14.0;
  static const double brandHeadingSize = 40.0;
  static const double fieldLabelFontSize = 11.0;
  static const double forgotPasswordFontSize = 13.0;
  static const double submitButtonFontSize = 15.0;
  static const double adminProductImageTileSize = 100.0;
  static const double reviewImageSize = 56.0;

  static const SizedBox spacingXs = SizedBox(height: 4, width: 4);
  static const SizedBox spacingSm = SizedBox(height: 8, width: 8);
  static const SizedBox spacingMd = SizedBox(height: 16, width: 16);
  static const SizedBox spacingLg = SizedBox(height: 24, width: 24);
  static const EdgeInsets screenPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(14);
}
