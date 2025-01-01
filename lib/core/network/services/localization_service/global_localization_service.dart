import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/network/constants/error_messages_key.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocalizationService)
class GlobalLocalizationService implements LocalizationService {
  AppLocalizations? _localizations;

  @override
  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
  }

  @override
  String translate(String messageKey) {
    if (_localizations == null) {
      return messageKey; // fallback if localizations not set
    }
    return _getLocalizedValue(messageKey);
  }

  String _getLocalizedValue(String messageKey) {
    switch (messageKey) {
      case ErrorMessagesKey.noInternet:
        return _localizations!.error_no_internet;
      case ErrorMessagesKey.connectionTimeout:
        return _localizations!.error_connection_timeout;
      case ErrorMessagesKey.serverError:
        return _localizations!.error_server_error;
      case ErrorMessagesKey.unauthorized:
        return _localizations!.error_unauthorized;
      case ErrorMessagesKey.forbidden:
        return _localizations!.error_forbidden;
      case ErrorMessagesKey.notFound:
        return _localizations!.error_not_found;
      default:
        return _localizations!.error_unknown;
    }
  }
}
