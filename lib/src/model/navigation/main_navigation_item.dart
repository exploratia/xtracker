import 'navigation.dart';
import 'navigation_item.dart';

class MainNavigationItem extends NavigationItem {
  final String Function() tooltipBuilder;

  MainNavigationItem({
    required this.tooltipBuilder,
    required super.iconData,
    required super.routeName,
    required super.titleBuilder,
  }) {
    Navigation.registerMainNavigationItem(this);
  }
}
