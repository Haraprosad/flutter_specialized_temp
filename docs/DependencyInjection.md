# Dependency Injection Guide

A comprehensive guide to understanding and implementing Dependency Injection in Flutter using `get_it` and `injectable`.

## Table of Contents
1. [Problems Without Dependency Injection](#problems-without-dependency-injection)
2. [How Dependency Injection Solves These Problems](#how-dependency-injection-solves-these-problems)
3. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
4. [When and How to Use Different Annotations](#when-and-how-to-use-different-annotations)
5. [Best Practices](#best-practices)
6. [Common Patterns](#common-patterns)

---

## Problems Without Dependency Injection

### 1. **Tight Coupling**
```dart
// ❌ Bad: Tightly coupled code
class UserRepository {
  final ApiService _apiService = ApiService(); // Hard dependency
  
  Future<User> getUser(String id) async {
    return await _apiService.fetchUser(id);
  }
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository = UserRepository(); // Hard dependency
  
  // Bloc logic...
}
```

**Problems:**
- Hard to test (can't mock dependencies)
- Difficult to change implementations
- Creates cascading dependencies

### 2. **Difficult Testing**
```dart
// ❌ Testing becomes nightmare
test('should fetch user', () async {
  final bloc = UserBloc(); // Can't inject mock repository
  // How do we mock the API calls? We can't!
});
```

### 3. **Memory Leaks**
```dart
// ❌ Multiple instances created unnecessarily
class ScreenA extends StatefulWidget {
  @override
  _ScreenAState createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  final DatabaseService db = DatabaseService(); // New instance
}

class ScreenB extends StatefulWidget {
  @override
  _ScreenBState createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  final DatabaseService db = DatabaseService(); // Another new instance!
}
```

### 4. **Initialization Order Problems**
```dart
// ❌ Manual dependency management
class App {
  late final SharedPreferences prefs;
  late final DatabaseService database;
  late final ApiService api;
  
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    database = DatabaseService(prefs); // Depends on prefs
    api = ApiService(database); // Depends on database
    // Complex initialization order management
  }
}
```

### 5. **Configuration Nightmares**
```dart
// ❌ Environment-specific configurations scattered everywhere
class ApiService {
  ApiService() {
    if (Environment.isDevelopment) {
      baseUrl = 'https://dev-api.example.com';
    } else if (Environment.isStaging) {
      baseUrl = 'https://staging-api.example.com';
    } else {
      baseUrl = 'https://api.example.com';
    }
  }
}
```

---

## How Dependency Injection Solves These Problems

### 1. **Loose Coupling**
```dart
// ✅ Good: Loosely coupled with DI
@injectable
class UserRepository {
  final ApiService _apiService;
  
  UserRepository(this._apiService); // Injected dependency
  
  Future<User> getUser(String id) async {
    return await _apiService.fetchUser(id);
  }
}

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  
  UserBloc(this._repository); // Injected dependency
}
```

### 2. **Easy Testing**
```dart
// ✅ Testing becomes simple
test('should fetch user', () async {
  final mockRepository = MockUserRepository();
  final bloc = UserBloc(mockRepository); // Easy to inject mock
  
  when(() => mockRepository.getUser('1'))
      .thenAnswer((_) async => User(id: '1', name: 'John'));
  
  // Test logic...
});
```

### 3. **Memory Efficiency**
```dart
// ✅ Single instance shared across app
@lazySingleton
class DatabaseService {
  // Only one instance created when first requested
}

// Both screens use the same instance
class ScreenA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = sl<DatabaseService>(); // Same instance
    return Container();
  }
}
```

### 4. **Automatic Dependency Resolution**
```dart
// ✅ DI container handles initialization order
@module
abstract class RegisterModule {
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @lazySingleton
  DatabaseService database(SharedPreferences prefs) => DatabaseService(prefs);
  
  @lazySingleton
  ApiService api(DatabaseService database) => ApiService(database);
}
```

---

## Step-by-Step Setup Guide

### Step 1: Add Dependencies

Add these packages to your `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^8.0.2
  injectable: ^2.5.0
  # Other dependencies...

dev_dependencies:
  injectable_generator: ^2.6.2
  build_runner: ^2.4.13
  # Other dev dependencies...
```

### Step 2: Create Injection Configuration

Create `lib/core/di/injection.dart`:

```dart
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(generateForDir: ['lib', 'test'])
Future<void> configureDependencies() async {
  try {
    await sl.init();
    AppLogger.i(message: '✅ Dependencies configured successfully');
  } catch (e) {
    AppLogger.e(message: '❌ Failed to configure dependencies: $e');
    rethrow;
  }
}
```

### Step 3: Create Register Module

Create `lib/core/di/register_module.dart`:

```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
// Import other third-party packages

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @preResolve
  Future<SharedPreferences> get sharedPreferences => 
      SharedPreferences.getInstance();
      
  // Add other third-party dependencies
}
```

### Step 4: Generate Injection Code

Run the build runner to generate injection configuration:

```bash
flutter pub get
flutter pub run build_runner build
```

This generates `injection.config.dart`.

### Step 5: Initialize DI in App

In your app initialization (like `app_initializer.dart`):

```dart
Future<void> initializeApp(Env env) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment config
    await dotenv.load(fileName: env.envFileName);
    
    // Configure environment
    EnvConfig.instantiate(
      appName: EnvConfig.createAppName(StringConstants.appName, env),
      baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
      env: env,
    );
    
    // Initialize DI - This line is crucial!
    await configureDependencies();
    
    // Configure BLoC observer
    Bloc.observer = AppBlocObserver();
    
    runApp(const MyApp());
  }, (exception, stackTrace) async {
    // Error handling...
  });
}
```

### Step 6: Annotate Your Classes

```dart
// Services
@lazySingleton
class ApiService {
  final Dio _dio;
  ApiService(this._dio);
}

// Repositories
@injectable
class UserRepository {
  final ApiService _apiService;
  UserRepository(this._apiService);
}

// BLoCs
@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  UserBloc(this._repository) : super(UserInitial());
}
```

### Step 7: Use Dependencies

```dart
// In your widgets
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserBloc>(),
      child: UserView(),
    );
  }
}

// Or inject directly
class SomeService {
  void doSomething() {
    final apiService = sl<ApiService>();
    // Use the service
  }
}
```

---

## When and How to Use Different Annotations

### @injectable
**When to use:**
- Default annotation for most classes
- When you need a new instance every time
- For BLoCs, Cubits, and form controllers

**Example:**
```dart
@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  UserBloc(this._repository) : super(UserInitial());
}

// Usage: Each time you call sl<UserBloc>(), you get a new instance
final bloc1 = sl<UserBloc>(); // New instance
final bloc2 = sl<UserBloc>(); // Another new instance
```

**Why new instances for BLoCs?**
- Each screen/widget should have its own BLoC instance
- Prevents state conflicts between different parts of the app
- Easier to manage lifecycle and disposal

### @singleton
**When to use:**
- When you need exactly ONE instance throughout the app's lifetime
- For services that maintain global state
- For expensive-to-create objects

**Example:**
```dart
@singleton
class GlobalConfigService {
  final Map<String, dynamic> _config = {};
  
  void setConfig(String key, dynamic value) {
    _config[key] = value;
  }
  
  T? getConfig<T>(String key) => _config[key] as T?;
}

// Usage: Always returns the same instance
final config1 = sl<GlobalConfigService>(); // First instance created
final config2 = sl<GlobalConfigService>(); // Same instance returned
print(identical(config1, config2)); // true
```

### @lazySingleton
**When to use:**
- When you need ONE instance but don't want to create it until first use
- For services that are expensive to initialize
- For most service classes (API, Database, Storage)

**Example:**
```dart
@lazySingleton
class DatabaseService {
  late final Database _database;
  
  DatabaseService() {
    print('DatabaseService created!'); // Only printed once, when first accessed
    _initDatabase();
  }
  
  void _initDatabase() {
    // Expensive initialization
  }
}

// Usage:
// DatabaseService is NOT created yet
final db1 = sl<DatabaseService>(); // NOW it's created and "DatabaseService created!" is printed
final db2 = sl<DatabaseService>(); // Same instance, no print
```

### @preResolve
**When to use:**
- For async dependencies that need to be resolved during DI setup
- For services that return Future (like SharedPreferences.getInstance())

**Example:**
```dart
@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => 
      SharedPreferences.getInstance();
      
  @preResolve
  Future<FirebaseApp> get firebaseApp => Firebase.initializeApp();
}
```

### Environment-Specific Registration
**When to use:**
- Different implementations for different environments (dev, staging, prod)

**Example:**
```dart
@Environment('dev')
@lazySingleton
class DevApiService implements ApiService {
  @override
  String get baseUrl => 'https://dev-api.example.com';
}

@Environment('prod')
@lazySingleton
class ProdApiService implements ApiService {
  @override
  String get baseUrl => 'https://api.example.com';
}

// Register with environment
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies(String environment) async => 
    $initGetIt(sl, environment: environment);
```

---

## Best Practices

### 1. **Service Layer Pattern**
```dart
// ✅ Good: Clear separation of concerns
@lazySingleton
class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthService(this._apiService, this._storageService);
  
  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    await _storageService.saveToken(response.token);
  }
}

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;
  
  LoginBloc(this._authService) : super(LoginInitial());
}
```

### 2. **Use Interfaces for Testability**
```dart
// ✅ Define interface
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
}

// ✅ Implementation
@injectable
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  
  UserRepositoryImpl(this._apiService, this._databaseService);
  
  @override
  Future<User> getUser(String id) async {
    // Implementation
  }
}

// ✅ Register interface
@module
abstract class RepositoryModule {
  @bind
  UserRepository bind(UserRepositoryImpl impl);
}
```

### 3. **Factory Pattern for Parameterized Objects**
```dart
// ✅ For objects that need runtime parameters
@injectable
class ReportGenerator {
  String generateReport(ReportType type, DateTime date) {
    // Generate report logic
  }
}

// Usage
class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final generator = sl<ReportGenerator>();
    final report = generator.generateReport(ReportType.monthly, DateTime.now());
    return Text(report);
  }
}
```

### 4. **Module Organization**
```dart
// ✅ Organize modules by domain
@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio();
  
  @lazySingleton
  ApiService api(Dio dio) => ApiService(dio);
}

@module
abstract class StorageModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => 
      SharedPreferences.getInstance();
      
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}

@module
abstract class RepositoryModule {
  @bind
  UserRepository bind(UserRepositoryImpl impl);
  
  @bind
  ProductRepository bind(ProductRepositoryImpl impl);
}
```

### 5. **Error Handling in DI**
```dart
// ✅ Handle DI errors gracefully (matches actual implementation)
@InjectableInit(generateForDir: ['lib', 'test'])
Future<void> configureDependencies() async {
  try {
    await sl.init();
    AppLogger.i(message: '✅ Dependencies configured successfully');
  } catch (e) {
    AppLogger.e(message: '❌ Failed to configure dependencies: $e');
    rethrow;
  }
}
```

---

## Common Patterns

### 1. **BLoC with Repository Pattern**
```dart
// Repository Layer
@injectable
class UserRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  
  UserRepository(this._apiService, this._databaseService);
  
  Future<User> getUser(String id) async {
    try {
      // Try to get from API first
      final user = await _apiService.getUser(id);
      await _databaseService.saveUser(user);
      return user;
    } catch (e) {
      // Fallback to local database
      return await _databaseService.getUser(id);
    }
  }
}

// BLoC Layer
@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  
  UserBloc(this._repository) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }
  
  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await _repository.getUser(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

// Widget Layer
class UserScreen extends StatelessWidget {
  final String userId;
  
  const UserScreen({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserBloc>()..add(LoadUser(userId)),
      child: UserView(),
    );
  }
}
```

### 2. **Service Composition Pattern**
```dart
@lazySingleton
class UserService {
  final UserRepository _userRepository;
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;
  
  UserService(
    this._userRepository,
    this._notificationService,
    this._analyticsService,
  );
  
  Future<void> updateUser(User user) async {
    await _userRepository.saveUser(user);
    await _notificationService.sendUpdateNotification(user);
    await _analyticsService.trackUserUpdate(user.id);
  }
}
```

### 3. **Configuration-Based Services**
```dart
@module
abstract class ConfigModule {
  @lazySingleton
  AppConfig config() {
    return AppConfig(
      apiBaseUrl: dotenv.env['API_BASE_URL']!,
      environment: dotenv.env['ENVIRONMENT']!,
      enableLogging: dotenv.env['ENABLE_LOGGING'] == 'true',
    );
  }
}

@injectable
class ApiService {
  final Dio _dio;
  final AppConfig _config;
  
  ApiService(this._dio, this._config) {
    _dio.options.baseUrl = _config.apiBaseUrl;
    if (_config.enableLogging) {
      _dio.interceptors.add(LogInterceptor());
    }
  }
}
```

Remember to run `flutter pub run build_runner build` after making changes to your DI configuration!
