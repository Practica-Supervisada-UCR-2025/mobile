import 'dart:io';

class PickerResult {
  final File? file;
  final String? errorMessage;

  PickerResult({this.file, this.errorMessage});
}
