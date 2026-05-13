import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/utils/state_messages.dart';

Widget errorWidgetWithAction({required dynamic apiCallFailureModel}) {
  stopLoading();

  showErrorMessage(message: apiCallFailureModel.translatedMessage as String);

  return Center(child: Text(apiCallFailureModel.translatedMessage as String));
}
