import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/info_type.dart';
import '../../widgets/administration/info_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class InfoScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.info_outline),
    routeName: '/info',
    titleBuilder: () => LocaleKeys.appTitle.tr(), // title is overridden in appBarBuilder
  );

  const InfoScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    var infoType = InfoType.byTypeName(args['infoType']);

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: Text(infoType.title() /*navItem.titleBuilder()*/)),
      bodyBuilder: (context) => InfoView(infoType: infoType),
    );
  }
}
