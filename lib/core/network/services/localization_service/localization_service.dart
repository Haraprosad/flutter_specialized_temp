
import 'package:flutter_specialized_temp/core/localization/l10n/app_localizations.dart';

abstract class LocalizationService {
  void setLocalizations(AppLocalizations localizations);
  String translate(String key);
}
