import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:flutter_specialized_temp/core/utils/state_messages.dart';

Widget errorWidgetWithAction({required dynamic apiCallFailureModel}) {
  stopLoading();

  final failure = apiCallFailureModel as ApiCallFailureModel;
  showErrorMessage(message: failure.translatedMessage);

  return Center(child: Text(failure.translatedMessage));
}
