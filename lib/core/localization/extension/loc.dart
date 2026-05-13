import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_specialized_temp/core/localization/l10n/app_localizations.dart';

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
