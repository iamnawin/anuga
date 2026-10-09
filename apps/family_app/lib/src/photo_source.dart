import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// A photo of a report, picked on the device. Nothing leaves the phone until
/// the user confirms the upload.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

/// Where photos come from. Widgets depend on this; tests pass a fake.
abstract class PhotoSource {
  /// [camera] true: take a photo; false: choose from the gallery. Null when cancelled.
  Future<PickedPhoto?> pick({required bool camera});
}

/// [PhotoSource] over the official `image_picker` plugin (on-device only).
/// Photos are scaled and compressed before upload to keep them under the vault limit.
class DevicePhotoSource implements PhotoSource {
  DevicePhotoSource([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick({required bool camera}) async {
    final file = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 85,
    );
    if (file == null) return null;
    final name = file.name.toLowerCase();
    final type = name.endsWith('.png')
        ? 'image/png'
        : name.endsWith('.webp')
        ? 'image/webp'
        : 'image/jpeg';
    return PickedPhoto(bytes: await file.readAsBytes(), contentType: file.mimeType ?? type);
  }
}
