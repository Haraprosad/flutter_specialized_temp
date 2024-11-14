class NavigationState {
  final int selectedTab;
  
  const NavigationState({
    this.selectedTab = 0,
  });
  
  NavigationState copyWith({
    int? selectedTab,
  }) {
    return NavigationState(
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}