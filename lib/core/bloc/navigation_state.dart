class NavigationState {
  const NavigationState({this.selectedTab = 0});
  final int selectedTab;

  NavigationState copyWith({int? selectedTab}) {
    return NavigationState(selectedTab: selectedTab ?? this.selectedTab);
  }
}
