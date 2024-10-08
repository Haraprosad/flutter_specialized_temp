import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';

class LocalizationActions {
  static void setLocale(BuildContext context, Locale locale) {
    context.read<LocaleBloc>().add(ChangeLocaleEvent(locale));
  }

  static Locale getLocale(BuildContext context) {
    return context.select((LocaleBloc bloc) => bloc.state.locale);
  }
}