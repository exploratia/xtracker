/// Available wallpaper motifs. Names are also used as stable storage values.
enum WallpaperStyle {
  hills,
  mountainLake,
  riverValley;

  /// Keeps existing installations and unknown future values on the original motif.
  static WallpaperStyle fromStorage(String? value) => values.firstWhere(
    (style) => style.name == value,
    orElse: () => hills,
  );
}
