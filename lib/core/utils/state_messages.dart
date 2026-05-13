import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> showSuccessMessage({required String message}) {
  return EasyLoading.showSuccess(message);
}

Future<void> showErrorMessage({required String message}) {
  return EasyLoading.showError(message);
}

Future<void> showLoading({required String message}) {
  return EasyLoading.show(status: message, maskType: EasyLoadingMaskType.black);
}

Future<void> showComingSoon() {
  return EasyLoading.showInfo("Coming Soon...");
}

Future<void> stopLoading() {
  return EasyLoading.dismiss();
}
