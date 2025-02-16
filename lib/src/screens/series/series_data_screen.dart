import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../model/navigation/navigation_item.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/view_type.dart';
import '../../providers/series_provider.dart';
import '../../util/globals.dart';
import '../../widgets/layout/app_bar_actions_divider.dart';
import '../../widgets/layout/centered_message.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/provider/data_provider_loader.dart';
import '../../widgets/responsive/screen_builder.dart';
import '../../widgets/series/data/view/series_data_view.dart';

class SeriesDataScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/series_data',
    titleBuilder: (t) => t.seriesDataTitle,
  );

  const SeriesDataScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    String seriesUuid = Globals.invalid;
    var seriesParameterValue = args['series'];
    if (seriesParameterValue is String) {
      if (Uuid.isValidUUID(fromString: seriesParameterValue)) {
        seriesUuid = seriesParameterValue;
      } else if (kDebugMode) {
        print('Got invalid arg series uuid!');
      }
    }

    return _ScreenBuilder(seriesUuid: seriesUuid);
  }
}

class _ScreenBuilder extends StatefulWidget {
  const _ScreenBuilder({required this.seriesUuid});

  final String seriesUuid;

  @override
  State<_ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<_ScreenBuilder> {
  SeriesDef? _seriesDef;
  ViewType _viewType = ViewType.chart;

  void _setSeriesDef(SeriesDef seriesDef) {
    setState(() {
      _seriesDef = seriesDef;
      _viewType = seriesDef.seriesType.viewTypes.first;
    });
  }

  void _setViewType(ViewType viewType) {
    setState(() {
      _viewType = viewType;
    });
  }

  void _addSeriesValueHandler(BuildContext context) async {
    await SeriesData.showSeriesDataInputDlg(context, _seriesDef!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    NavigationItem navItem = SeriesDataScreen.navItem;

    String title = _seriesDef?.name ?? navItem.titleBuilder(t);

    Widget view;
    if (widget.seriesUuid == Globals.invalid) {
      view = const CenteredMessage(message: 'Got invalid series id!');
      // WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
    } else {
      view = DataProviderLoader(
        obtainDataProviderFuture: context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
        child: _SeriesDataViewTitleWrapper(
          seriesUuid: widget.seriesUuid,
          setSeriesDef: _setSeriesDef,
          appBarTitle: title,
          viewType: _viewType,
        ),
      );
    }

    List<Widget> actions = [];
    if (_seriesDef != null) {
      actions = [
        // TODO conditional depending on chart switches: const AppBarActionsDivider(),
        // show buttons for all available view types without the active one
        ..._seriesDef!.seriesType.viewTypes.where((vt) => vt != _viewType).map((vt) => IconButton(onPressed: () => _setViewType(vt), icon: Icon(vt.iconData))),
        const AppBarActionsDivider(),
        // add value btn
        IconButton(onPressed: () => _addSeriesValueHandler(context), icon: const Icon(Icons.add)),
      ];
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: Text(title), actions: actions),
      bodyBuilder: (context) => view,
    );
  }
}

/// read series def from provider -> set AppBar title and then show series data
class _SeriesDataViewTitleWrapper extends StatelessWidget {
  const _SeriesDataViewTitleWrapper({required this.seriesUuid, required this.setSeriesDef, required this.appBarTitle, required this.viewType});

  final String seriesUuid;
  final String appBarTitle;

  final Function(SeriesDef seriesDef) setSeriesDef;
  final ViewType viewType;

  @override
  Widget build(BuildContext context) {
    SeriesDef? seriesDef = context.read<SeriesProvider>().getSeries(seriesUuid);

    if (seriesDef == null) {
      return const CenteredMessage(message: 'No series found for given id!');
    }

    // set title and actions if not already correct
    if (appBarTitle != seriesDef.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setSeriesDef(seriesDef));
      return Container();
    }

    return SeriesDataView(
      seriesDef: seriesDef,
      viewType: viewType,
    );
  }
}
