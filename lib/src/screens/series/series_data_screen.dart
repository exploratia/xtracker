import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../model/series/view_type.dart';
import '../../providers/series_provider.dart';
import '../../util/globals.dart';
import '../../util/theme_utils.dart';
import '../../widgets/controls/appbar/app_bar_actions_divider.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/layout/centered_message.dart';
import '../../widgets/controls/popupmenu/icon_popup_menu.dart';
import '../../widgets/controls/provider/data_provider_loader.dart';
import '../../widgets/controls/responsive/screen_builder.dart';
import '../../widgets/controls/text/overflow_text.dart';
import '../../widgets/series/data/view/series_data_view.dart';

class SeriesDataScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/series_data',
    titleBuilder: () => LocaleKeys.seriesData_title.tr(),
  );

  /// args(series) = seriesDef | seriesDefUuid
  const SeriesDataScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    String seriesUuid = Globals.invalid;
    SeriesDef? seriesDef;
    var seriesParameterValue = args['series'];
    if (seriesParameterValue is String) {
      if (Uuid.isValidUUID(fromString: seriesParameterValue)) {
        seriesUuid = seriesParameterValue;
      } else if (kDebugMode) {
        print('Got invalid arg series uuid!');
      }
    } else if (seriesParameterValue is SeriesDef) {
      seriesDef = seriesParameterValue;
      seriesUuid = seriesDef.uuid;
    }

    return _ScreenBuilder(seriesUuid: seriesUuid, seriesDef: seriesDef);
  }
}

class _ScreenBuilder extends StatefulWidget {
  const _ScreenBuilder({required this.seriesUuid, this.seriesDef});

  final String seriesUuid;
  final SeriesDef? seriesDef;

  @override
  State<_ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<_ScreenBuilder> {
  SeriesDef? _seriesDef;
  ViewType _viewType = ViewType.lineChart;
  bool _editMode = false;
  bool _showCompressed = false;

  @override
  void initState() {
    _seriesDef = widget.seriesDef;
    if (_seriesDef != null) {
      _viewType = _seriesDef!.seriesType.viewTypes.last;
    }
    super.initState();
  }

  void _setSeriesDef(SeriesDef seriesDef) {
    setState(() {
      _seriesDef = seriesDef;
      _viewType = seriesDef.seriesType.viewTypes.last;
    });
  }

  void _setViewType(ViewType viewType) {
    setState(() {
      _viewType = viewType;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  void _toggleCompressedMode() {
    setState(() {
      _showCompressed = !_showCompressed;
    });
  }

  void _addSeriesValueHandler(BuildContext context) async {
    await SeriesData.showSeriesDataInputDlg(context, _seriesDef!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    NavigationItem navItem = SeriesDataScreen.navItem;

    Widget title;
    if (_seriesDef != null) {
      title = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 24) {
            return const SizedBox();
          }
          if (constraints.maxWidth < 55) {
            return Icon(_viewType.iconData, color: themeData.colorScheme.onPrimary);
          }
          return Row(
            spacing: ThemeUtils.horizontalSpacing,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_viewType.iconData, color: themeData.colorScheme.onPrimary),
              OverflowText(ViewType.displayNameOf(_viewType)),
            ],
          );
        },
      );
    } else {
      title = Text(navItem.titleBuilder());
    }

    Widget view;
    if (widget.seriesUuid == Globals.invalid) {
      view = const CenteredMessage(message: 'Got invalid series id!');
      // pop screen if no series id is available.
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
    } else if (_seriesDef != null) {
      view = _SeriesDataViewTitleWrapper(
        seriesUuid: widget.seriesUuid,
        setSeriesDef: _setSeriesDef,
        useSeriesCallback: _seriesDef == null,
        viewType: _viewType,
        editMode: _editMode,
        showCompressed: _showCompressed,
      );
    } else {
      view = DataProviderLoader(
        obtainDataProviderFuture: context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
        child: _SeriesDataViewTitleWrapper(
          seriesUuid: widget.seriesUuid,
          setSeriesDef: _setSeriesDef,
          useSeriesCallback: _seriesDef == null,
          viewType: _viewType,
          editMode: _editMode,
          showCompressed: _showCompressed,
        ),
      );
    }

    List<Widget> actions = [];

    if (_seriesDef != null) {
      var seriesType = _seriesDef!.seriesType;

      List<Widget> dataActions = [
        // add value btn
        IconButton(
          tooltip: LocaleKeys.seriesData_action_addValue_tooltip.tr(),
          onPressed: () => _addSeriesValueHandler(context),
          icon: const Icon(Icons.add),
        ),
      ];

      List<Widget> viewActions = [
        Padding(
          padding: const EdgeInsets.only(right: ThemeUtils.defaultPadding),
          child: Tooltip(
            message: LocaleKeys.seriesData_action_viewTypeMenu_tooltip.tr(),
            child: IconPopupMenu(
              icon: const Icon(Icons.remove_red_eye_outlined),
              menuEntries: [
                ...seriesType.viewTypes.where((vt) => vt != _viewType).map(
                      (vt) => IconPopupMenuEntry(Icon(vt.iconData), () => _setViewType(vt), vt.displayName()),
                    ),
              ],
            ),
          ),
        ),
      ];

      // in table add edit-mode
      if (_viewType == ViewType.table) {
        dataActions.insert(
          0,
          IconButton(
            tooltip: _editMode ? LocaleKeys.seriesData_action_disableEditMode_tooltip.tr() : LocaleKeys.seriesData_action_enableEditMode_tooltip.tr(),
            onPressed: () => _toggleEditMode(),
            icon: Icon(_editMode ? Icons.edit_off_outlined : Icons.edit_outlined),
          ),
        );
      }

      // in charts add depending on series type switch interval (month/year) btn
      if (_viewType == ViewType.lineChart || _viewType == ViewType.barChart) {
        if (/*seriesType == SeriesType.monthly ||*/ seriesType == SeriesType.dailyCheck || seriesType == SeriesType.habit) {
          // monthly | yearly
          var tooltip = _showCompressed ? LocaleKeys.seriesData_action_monthlyView_tooltip.tr() : LocaleKeys.seriesData_action_yearlyView_tooltip.tr();
          if (seriesType == SeriesType.habit) {
            // daily | monthly
            tooltip = _showCompressed ? LocaleKeys.seriesData_action_dailyView_tooltip.tr() : LocaleKeys.seriesData_action_monthlyView_tooltip.tr();
          }

          viewActions.insert(
            0,
            IconButton(
              tooltip: tooltip,
              onPressed: () => _toggleCompressedMode(),
              icon: Icon(_showCompressed ? Icons.calendar_month_outlined : Icons.calendar_today_outlined),
            ),
          );
        }
      }

      // Divider necessary?
      if (viewActions.isNotEmpty && dataActions.isNotEmpty) dataActions.add(const AppBarActionsDivider());

      actions = [
        ...dataActions,
        ...viewActions,
      ];
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: title, actions: actions),
      bodyBuilder: (context) => view,
    );
  }
}

/// read series def from provider -> set AppBar title and then show series data
class _SeriesDataViewTitleWrapper extends StatelessWidget {
  const _SeriesDataViewTitleWrapper(
      {required this.seriesUuid,
      required this.setSeriesDef,
      required this.useSeriesCallback,
      required this.viewType,
      required this.editMode,
      required this.showCompressed});

  final String seriesUuid;
  final bool useSeriesCallback;

  final Function(SeriesDef seriesDef) setSeriesDef;
  final ViewType viewType;
  final bool editMode;
  final bool showCompressed;

  @override
  Widget build(BuildContext context) {
    SeriesDef? seriesDef = context.read<SeriesProvider>().getSeries(seriesUuid);

    if (seriesDef == null) {
      return const CenteredMessage(message: 'No series found for given id!');
    }

    // set title and actions if not already correct
    if (useSeriesCallback) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setSeriesDef(seriesDef));
      return Container();
    }

    return SeriesDataView(
      seriesViewMetaData: SeriesViewMetaData(
        seriesDef: seriesDef,
        viewType: viewType,
        editMode: editMode,
        showCompressed: showCompressed,
      ),
    );
  }
}
