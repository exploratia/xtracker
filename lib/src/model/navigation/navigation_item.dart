import 'abstract_navigation_item.dart';
import 'navigation.dart';

class NavigationItem extends AbstractNavigationItem {
  NavigationItem(
      {required super.icon,
      required super.routeName,
      required super.titleBuilder,
      required super.screenBuilder}) {
    Navigation.navigationItems.add(this);
  }
}
