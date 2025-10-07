import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

Future<List<String>> pickImages() async {
  final picker = ImagePicker();
  final imgs = await picker.pickMultiImage(imageQuality: 85);
  return imgs.map((x) => x.path).toList();
}

Future<String?> pickVideo() async {
  final res = await FilePicker.platform
      .pickFiles(type: FileType.video, allowMultiple: false);
  return res?.files.single.path;
}
