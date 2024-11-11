part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class InitializeLocale extends LocaleEvent {
  const InitializeLocale();
}

class ChangeLocaleEvent extends LocaleEvent {
  final Locale locale;

  const ChangeLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}