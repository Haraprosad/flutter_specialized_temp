import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.d(message: 'BlocObserver: onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.d(
      message: 'BlocObserver: onEvent -- ${bloc.runtimeType}, $event',
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d(
      message:
          '''
      BlocObserver: onChange -- ${bloc.runtimeType}
      CurrentState: ${change.currentState}
      NextState: ${change.nextState}''',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    AppLogger.d(
      message:
          '''
      BlocObserver: onTransition -- ${bloc.runtimeType}
      Event: ${transition.event}
      CurrentState: ${transition.currentState}
      NextState: ${transition.nextState}''',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      message: 'BlocObserver: onError -- ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
