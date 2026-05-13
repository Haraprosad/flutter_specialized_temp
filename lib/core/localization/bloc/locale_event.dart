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
  const ChangeLocaleEvent(this.locale);
  final Locale locale;

  @override
  List<Object?> get props => [locale];
}
