import 'package:file_picker/file_picker.dart';

void main() {
  print('FilePicker class exists!');
  try {
    final picker = FilePicker.platform;
    print('platform is accessible: $picker');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
