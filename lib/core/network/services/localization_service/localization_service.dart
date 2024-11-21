import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class LocalizationService {
  void setLocalizations(AppLocalizations localizations);
  String translate(String key);
}
