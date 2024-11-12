class ResponseCode {
  static const int SUCCESS = 200; // success with data
  static const int NO_CONTENT = 201; // success with no data (no content)
  static const int BAD_REQUEST = 400; // failure, API rejected request
  static const int UNAUTHORISED = 401; // failure, user is not authorised
  static const int FORBIDDEN =
      403; //  failure, API rejected request // failure, crash in server side
  static const int NOT_FOUND = 404;

  static const int TIMEOUT = 408;
  static const int NO_INTERNET = 503;
  static const int SERVER_ERROR = 500;
  static const int DEFAULT = -1;
  static const int CONNECTION_ERROR = 503; // failure, not found
}
