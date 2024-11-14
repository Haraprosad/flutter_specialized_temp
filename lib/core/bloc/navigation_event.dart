abstract class NavigationEvent {}

class NavigationTabChanged extends NavigationEvent {
  final int index;
  
  NavigationTabChanged(this.index);
}