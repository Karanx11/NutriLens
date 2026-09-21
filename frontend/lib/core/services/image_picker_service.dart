/// Abstraction over capturing or picking a product photo.
///
/// The demo build does not bundle a native camera plugin, so these methods are
/// intentionally lightweight placeholders. When you add the `image_picker`
/// package, implement them to return the captured file path and the scanner
/// flow will pass it straight through to [ScanService].
class ImagePickerService {
  const ImagePickerService();

  Future<String?> captureFromCamera() async => null;

  Future<String?> pickFromGallery() async => null;
}
