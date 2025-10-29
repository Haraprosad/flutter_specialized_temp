// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get flutter_template => 'Flutter Template';

  @override
  String get error_no_internet => 'No internet connection available';

  @override
  String get error_connection_timeout =>
      'Connection timeout. Please check your internet connection.';

  @override
  String get error_server_error => 'Server error occurred';

  @override
  String get error_unauthorized => 'Unauthorized access';

  @override
  String get error_forbidden => 'Access forbidden';

  @override
  String get error_not_found => 'Resource not found';

  @override
  String get error_bad_request => 'Bad Request';

  @override
  String get error_send_timeout => 'Send timeout error. Please try again.';

  @override
  String get error_receive_timeout =>
      'Receive timeout error. Please try again.';

  @override
  String get error_connection_error =>
      'Connection error. Please check your internet connection.';

  @override
  String get error_cancel => 'Request cancelled.';

  @override
  String get error_bad_certificate =>
      'Invalid certificate. Please check your security settings.';

  @override
  String get error_unknown => 'An unexpected error occurred.';

  @override
  String get error_pre_call => 'Error before API call';

  @override
  String get error_parsing => 'Error parsing the response data';

  @override
  String get try_again => 'Try Again';

  @override
  String get home => 'Home';
}
