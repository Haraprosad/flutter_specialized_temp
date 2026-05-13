abstract class NavigationEvent {}

class NavigationTabChanged extends NavigationEvent {
  NavigationTabChanged(this.index);
  final int index;
}
