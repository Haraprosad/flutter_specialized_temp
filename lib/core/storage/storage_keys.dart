class StorageKeys {
  StorageKeys._(); // Private constructor
  
  // Theme related keys
  static const String isDarkMode = 'isDarkMode';
  static const String themeColor = 'themeColor';
  
  // User preference keys (non-sensitive)
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String fontSize = 'fontSize';
  
  // Secure storage keys (sensitive data)
  static const String authToken = 'authToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String userPin = 'userPin';
  static const String biometricEnabled = 'biometricEnabled';
}
