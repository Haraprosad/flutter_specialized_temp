import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:injectable/injectable.dart';

part 'locale_event.dart';
part 'locale_state.dart';

@singleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._storage) : super(const LocaleState(LocaleConstants.english)) {
    on<ChangeLocaleEvent>(_onChangeLocale);
    on<InitializeLocale>(_onInitializeLocale);
  }

  final AppStorage _storage;

  void _onChangeLocale(ChangeLocaleEvent event, Emitter<LocaleState> emit) async {
    try {
      // Don't update if the locale is the same
      if (event.locale == state.locale) {
        return;
      }

      // Validate the locale before emitting it
      if (AppLocalizations.supportedLocales.contains(event.locale)) {
        await _storage.preferences.setLanguage(event.locale.languageCode);
        emit(LocaleState(event.locale));
      } else {
        // Invalid locale, fallback to English
        await _storage.preferences.setLanguage(LocaleConstants.english.languageCode);
        emit(const LocaleState(LocaleConstants.english));
      }
    } catch (e) {
      // Handle any potential errors by falling back to English
      await _storage.preferences.setLanguage(LocaleConstants.english.languageCode);
      emit(const LocaleState(LocaleConstants.english));
    }
  }

  Future<void> _onInitializeLocale(
    InitializeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final languageCode = _storage.preferences.getLanguage();
    emit(LocaleState(Locale(languageCode)));
  }
}