import 'package:flutter_ecommerce/app/router/app_routes.dart';

class NavigationHistory {
  // A stack of tab routes visited
  static final List<String> _tabHistory = [];

  // Track the current active tab to avoid adding duplicates or consecutive visits
  static String? _currentTab;

  static void pushTab(String routeName, {bool replace = false}) {
    if (_currentTab == routeName) return;
    if (replace) {
      if (_tabHistory.isNotEmpty) {
        _tabHistory[_tabHistory.length - 1] = routeName;
      } else {
        _tabHistory.add(routeName);
      }
      _currentTab = routeName;
      return;
    }
    _currentTab = routeName;
    _tabHistory.remove(routeName);
    _tabHistory.add(routeName);
    if (_tabHistory.length > 10) {
      _tabHistory.removeAt(0);
    }
  }

  static String? popTab() {
    if (_tabHistory.length > 1) {
      // Remove current tab
      _tabHistory.removeLast();
      // Get the previous tab
      final prevTab = _tabHistory.last;
      _currentTab = prevTab;
      return prevTab;
    }
    return null;
  }
  
  static void clear() {
    _tabHistory.clear();
    _currentTab = null;
  }

  static List<String> get history => List.unmodifiable(_tabHistory);
  static String? get currentTab => _currentTab;
}
