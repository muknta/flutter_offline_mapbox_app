import 'package:image_picker/image_picker.dart';

class AlreadyExistsException implements Exception {
  const AlreadyExistsException();
}

class NotFoundException implements Exception {
  const NotFoundException();
}

class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException();
}

class FailedFilesException implements Exception {
  const FailedFilesException(this.files);

  final List<XFile> files;
}
