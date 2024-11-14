import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/network/constants/error_messages_key.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';

/// Global localization service to retrieve translated messages.
class GlobalLocalizationService implements LocalizationService {
  final BuildContext context;

  GlobalLocalizationService(this.context);

  /// Returns translated messages for the provided [messageKey].
  @override
  String translate(String messageKey) {
    return _getLocalizedValue(messageKey);
  }

  /// Internal method to get the localized value based on [messageKey].
  String _getLocalizedValue(String messageKey) {
    switch (messageKey) {
      case ErrorMessagesKey.noInternet:
        return context.loc.error_no_internet;
      case ErrorMessagesKey.connectionTimeout:
        return context.loc.error_connection_timeout;
      case ErrorMessagesKey.serverError:
        return context.loc.error_server_error;
      case ErrorMessagesKey.unauthorized:
        return context.loc.error_unauthorized;
      case ErrorMessagesKey.forbidden:
        return context.loc.error_forbidden;
      case ErrorMessagesKey.notFound:
        return context.loc.error_not_found;
      default:
        return context.loc.error_unknown;
    }
  }
}
