import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_event.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_state.dart';
import 'package:injectable/injectable.dart';

@singleton
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChanged>(_onTabChanged);
  }
  
  void _onTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }
}