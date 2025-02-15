import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/navigation_item.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';
import '../../widgets/series/data/series_data_view.dart';

class SeriesDataScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/series/data',
    titleBuilder: (t) => t.seriesDataTitle,
  );

  const SeriesDataScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    String seriesUuid = 'INVALID';
    var seriesParameterValue = args['series'];
    if (seriesParameterValue is String) {
      seriesUuid = seriesParameterValue;
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: Text(navItem.titleBuilder(t))),
      bodyBuilder: (context) => SeriesDataView(seriesUuid: seriesUuid),
    );
  }
}
