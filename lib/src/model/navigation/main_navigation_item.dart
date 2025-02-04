import 'abstract_navigation_item.dart';
import 'navigation.dart';

class MainNavigationItem extends AbstractNavigationItem {
  MainNavigationItem(
      {required super.icon,
      required super.routeName,
      required super.titleBuilder,
      required super.screenBuilder}) {
    Navigation.registerMainNavigationItem(this);
  }
}
