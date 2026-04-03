import 'package:termos_ui/termos_ui.dart';

import 'gallery_test_text_styles.dart';

/// Fixed [TermosThemeData] for README/GIF captures and smoke tests.
///  
/// Uses [galleryTestTextStyles] so `flutter test` does not fetch Google Fonts over HTTP.
/// Colors and dot grid match [TermosThemeData.dark] defaults.
TermosThemeData galleryCaptureTheme() {
  const dotGrid = DotGridConfig();
  return TermosThemeData(
    colors: TermosColors.dark,
    dotGrid: dotGrid,
    textStyles: galleryTestTextStyles(TermosColors.dark),
  );
}
