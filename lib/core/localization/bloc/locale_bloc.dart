import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<ChangeLocaleEvent>(_onChangeLocale);
  }

void _onChangeLocale(ChangeLocaleEvent event, Emitter<LocaleState> emit) {
  try {
    // Validate the locale before emitting it
    if (AppLocalizations.supportedLocales.contains(Locale(event.locale.languageCode))) {
      if (event.locale != state.locale) {
        emit(LocaleState(event.locale));
      }
    } else {
      // Invalid locale, fallback to English
      emit(const LocaleState(LocaleConstants.english));
    }
  } catch (e) {
    // Handle any potential errors
    emit(const LocaleState(LocaleConstants.english)); // Fallback to English
  }
}

}
