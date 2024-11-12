class ErrorMessagesKey {
  //For no internet
  static const String noInternet = 'error_no_internet';

  //For dio bad response
  static const String serverError = 'error_server_error';
  static const String unauthorized = 'error_unauthorized';
  static const String forbidden = 'error_forbidden';
  static const String notFound = 'error_not_found';
  static const String badRequest = 'error_bad_request';

  //for dio exception
  static const String connectionTimeout = 'error_connection_timeout';
  static const String sendTimeout = 'error_connection_timeout';
  static const String receiveTimeout = 'error_connection_timeout';
  static const String connectionError = 'error_connection_error';
  static const String cancel = 'error_cancel';
  static const String badCertificate = 'error_bad_certificate';
  
  //For unknown error
  static const String unknown = 'error_unknown';

  //For custom exception
  static const String preCall = 'error_pre_call';
  static const String parsing = 'error_parsing';

}