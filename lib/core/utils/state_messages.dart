import 'package:flutter_easyloading/flutter_easyloading.dart';

  

showSuccessMessage({required String message}){

return EasyLoading.showSuccess(message);

}

  

showErrorMessage({required String message}){

return EasyLoading.showError(message);

}

  

showLoading({required String message}){

return EasyLoading.show(status: message, maskType: EasyLoadingMaskType.black);

}

  

showComingSoon(){

return EasyLoading.showInfo("Coming Soon...");

}

  

stopLoading(){

return EasyLoading.dismiss();

}