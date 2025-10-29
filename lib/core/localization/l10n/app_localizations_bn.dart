// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get flutter_template => 'ফ্ল্যাটার টেমপ্লেট';

  @override
  String get error_no_internet => 'কোন ইন্টারনেট সংযোগ নেই';

  @override
  String get error_connection_timeout =>
      'সংযোগ সময়সীমা শেষ। দয়া করে আপনার ইন্টারনেট সংযোগ চেক করুন।';

  @override
  String get error_server_error => 'সার্ভার ত্রুটি ঘটেছে';

  @override
  String get error_unauthorized => 'অননুমোদিত প্রবেশ';

  @override
  String get error_forbidden => 'প্রবেশ নিষিদ্ধ';

  @override
  String get error_not_found => 'রিসোর্স পাওয়া যায়নি';

  @override
  String get error_bad_request => 'ত্রুটিপূর্ণ অনুরোধ';

  @override
  String get error_send_timeout =>
      'তথ্য প্রেরণে সময়সীমা শেষ। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get error_receive_timeout =>
      'তথ্য গ্রহণে সময়সীমা শেষ। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get error_connection_error =>
      'সংযোগ ত্রুটি। দয়া করে আপনার ইন্টারনেট সংযোগ চেক করুন।';

  @override
  String get error_cancel => 'অনুরোধ বাতিল করা হয়েছে।';

  @override
  String get error_bad_certificate =>
      'অবৈধ সার্টিফিকেট। দয়া করে আপনার নিরাপত্তা সেটিংস চেক করুন।';

  @override
  String get error_unknown => 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে।';

  @override
  String get error_pre_call => 'এপিআই কলের আগে ত্রুটি';

  @override
  String get error_parsing => 'প্রতিক্রিয়া ডেটা পার্স করার সময় ত্রুটি';

  @override
  String get try_again => 'আবার চেষ্টা করুন';

  @override
  String get home => 'হোম';
}
