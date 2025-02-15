import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../model/navigation/navigation_item.dart';
import '../../util/globals.dart';
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

    String seriesUuid = Globals.invalid;
    var seriesParameterValue = args['series'];
    if (seriesParameterValue is String) {
      if (Uuid.isValidUUID(fromString: seriesParameterValue)) {
        seriesUuid = seriesParameterValue;
      } else if (kDebugMode) {
        print('Got invalid series uuid!');
      }
    }

    Widget view;
    if (seriesUuid == Globals.invalid) {
      view = Center(child: Text(seriesUuid));
    } else {
      view = SeriesDataView(seriesUuid: seriesUuid);
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: Text(navItem.titleBuilder(t))),
      bodyBuilder: (context) => view,
    );
  }
}
