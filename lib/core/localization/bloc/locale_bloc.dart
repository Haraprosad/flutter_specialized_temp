import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<ChangeLocaleEvent>(_onChangeLocale);
  }

  void _onChangeLocale(ChangeLocaleEvent event, Emitter<LocaleState> emit) {
    try {
      if (event.locale != state.locale) {
        emit(LocaleState(event.locale));
      }
    } catch (e) {
      // Handle any potential errors
      emit(const LocaleState(LocaleConstants.bengali)); // Fallback to English
    }
  }
}
