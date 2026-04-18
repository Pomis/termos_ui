import 'package:flutter/widgets.dart';

import 'gallery_widget_demos.dart';

/// IDs for capture/output folders and GIF basenames.
abstract final class GalleryCaptureIds {
  static const button = 'button';
  static const backButton = 'back_button';
  static const loadingIndicator = 'loading_indicator';
  static const group = 'group';
  static const segmented = 'segmented';
  static const switchDemo = 'switch';
  static const timePicker = 'time_picker';
  static const textField = 'text_field';
  static const navBar = 'nav_bar';
  static const crt = 'crt';
  static const sliders = 'sliders';
  static const expandableSection = 'expandable_section';
  static const glowTopBorder = 'glow_top_border';
  static const reactiveStarfield = 'reactive_starfield';
  static const scanlines = 'scanlines';
}

/// Single source for widget tests and GIF frame export: id → demo root widget.
///
/// Demos use [TermosTheme.of]; wrap with [TermosTheme] when pumping.
final Map<String, WidgetBuilder> galleryCaptureDemoBuilders = {
  GalleryCaptureIds.button: (_) => const GalleryButtonDemo(),
  GalleryCaptureIds.backButton: (_) => const GalleryBackButtonDemo(),
  GalleryCaptureIds.loadingIndicator: (_) => const GalleryLoaderDemo(
        interactive: false,
        transitionKey: 0,
      ),
  GalleryCaptureIds.group: (_) => const GalleryDraggableSquaresDemo(),
  GalleryCaptureIds.segmented: (_) => const GallerySegmentedDemo(),
  GalleryCaptureIds.switchDemo: (_) => const GallerySwitchDemo(),
  GalleryCaptureIds.timePicker: (_) => const GalleryTimePickerDemo(),
  GalleryCaptureIds.textField: (_) => const GalleryTextFieldDemo(),
  GalleryCaptureIds.navBar: (_) => const GalleryNavBarDemo(),
  GalleryCaptureIds.crt: (_) => const GalleryCrtDemo(),
  GalleryCaptureIds.sliders: (_) => const GallerySliderShowcase(),
  GalleryCaptureIds.expandableSection: (_) =>
      const GalleryExpandableSectionDemo(),
  GalleryCaptureIds.glowTopBorder: (_) => const GalleryGlowTopBorderDemo(),
  GalleryCaptureIds.reactiveStarfield: (_) => const GalleryReactiveStarfieldDemo(),
  GalleryCaptureIds.scanlines: (_) => const GalleryScanlinesDemo(),
};

/// Demos that should not be exported as README GIFs.
final Set<String> galleryGifExcludedIds = {
  GalleryCaptureIds.group,
  GalleryCaptureIds.scanlines,
};

/// Filtered entries for GIF generation / golden export.
Iterable<MapEntry<String, WidgetBuilder>> get galleryGifDemoEntries =>
    galleryCaptureDemoBuilders.entries.where(
      (entry) => !galleryGifExcludedIds.contains(entry.key),
    );
