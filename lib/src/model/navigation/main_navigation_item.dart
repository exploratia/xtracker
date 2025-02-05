import 'navigation.dart';
import 'navigation_item.dart';

class MainNavigationItem extends NavigationItem {
  MainNavigationItem({
    required super.icon,
    required super.routeName,
    required super.titleBuilder,
  }) {
    Navigation.registerMainNavigationItem(this);
  }
}
