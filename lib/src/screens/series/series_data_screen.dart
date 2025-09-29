import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/column_profile/fix_column_profile.dart';
import '../../model/column_profile/fix_column_profile_type.dart';
import '../../model/navigation/navigation_item.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/data/series_data_filter.dart';
import '../../model/series/data/series_data_value.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../model/series/view_type.dart';
import '../../providers/series_data_provider.dart';
import '../../providers/series_provider.dart';
import '../../util/date_time_utils.dart';
import '../../util/globals.dart';
import '../../util/media_query_utils.dart';
import '../../util/theme_utils.dart';
import '../../util/tooltip_utils.dart';
import '../../widgets/controls/appbar/app_bar_actions_divider.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/layout/centered_message.dart';
import '../../widgets/controls/layout/h_centered_scroll_view.dart';
import '../../widgets/controls/navigation/app_bottom_navigation_bar.dart';
import '../../widgets/controls/popupmenu/icon_popup_menu.dart';
import '../../widgets/controls/provider/data_provider_loader.dart';
import '../../widgets/controls/responsive/screen_builder.dart';
import '../../widgets/controls/text/overflow_text.dart';
import '../../widgets/series/data/analytics/series_data_analytics_view.dart';
import '../../widgets/series/data/view/series_data_no_data.dart';
import '../../widgets/series/data/view/series_data_view.dart';
import '../../widgets/series/data/view/series_data_view_content_builder.dart';
import '../../widgets/series/data/view/series_data_view_overlays.dart';
import '../../widgets/series/data/view/series_title.dart';

class SeriesDataScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.settings_outlined,
    routeName: '/series_data',
    titleBuilder: () => LocaleKeys.seriesData_title.tr(),
  );

  /// args(series) = seriesDef | seriesDefUuid
  const SeriesDataScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    TooltipUtils.updateTooltipMonospaceStyle(context);
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

    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
      child: _SeriesDefLoader(
        seriesUuid: seriesUuid,
        seriesDef: seriesDef,
        builder: (SeriesViewMetaData? seriesViewMetaData) {
          if (seriesViewMetaData == null) {
            // pop screen if no series is available.
            WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
            return const CenteredMessage(message: 'Invalid series!');
          }

          return DataProviderLoader(
            obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesViewMetaData.seriesDef),
            child: _SeriesDataFilterWrapper(
              seriesViewMetaData: seriesViewMetaData,
              builder: (SeriesDataFilter filter, VoidCallback updateFilter) {
                return _SeriesDataViewOverlaysWrapper(
                  builder: (SeriesDataViewOverlays seriesDataViewOverlays, void Function({double? topHeight, double? bottomHeight}) updateOverlays) {
                    return SeriesDataViewContentBuilder(
                      seriesViewMetaData: seriesViewMetaData,
                      seriesDataFilter: filter,
                      seriesDataViewOverlays: seriesDataViewOverlays,
                      builder: (Widget Function() seriesDataViewBuilder, List<SeriesDataValue> seriesDataValues) {
                        return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
                          var isLandscape = orientation == Orientation.landscape;
                          return _ScreenBuilder(
                            seriesViewMetaData: seriesViewMetaData,
                            seriesDataViewBuilder: seriesDataViewBuilder,
                            seriesDataValues: seriesDataValues,
                            filter: filter,
                            updateFilter: updateFilter,
                            seriesDataViewOverlays: seriesDataViewOverlays,
                            updateOverlays: updateOverlays,
                            isLandScape: isLandscape,
                          );
                        });
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ScreenBuilder extends StatefulWidget {
  const _ScreenBuilder({
    required this.seriesViewMetaData,
    required this.seriesDataViewBuilder,
    required this.seriesDataValues,
    required this.filter,
    required this.updateFilter,
    required this.seriesDataViewOverlays,
    required this.updateOverlays,
    required this.isLandScape,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final bool isLandScape;
  final SeriesDataFilter filter;
  final VoidCallback updateFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;
  final void Function({double? topHeight, double? bottomHeight}) updateOverlays;
  final Widget Function() seriesDataViewBuilder;
  final List<SeriesDataValue> seriesDataValues;

  @override
  State<_ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<_ScreenBuilder> {
  bool _isLandscapeMode = false;

  @override
  void initState() {
    _isLandscapeMode = widget.isLandScape;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ScreenBuilder oldWidget) {
    _isLandscapeMode = widget.isLandScape;
    super.didUpdateWidget(oldWidget);
  }

  void _setViewType(ViewType viewType) {
    setState(() {
      widget.seriesViewMetaData.viewType = viewType;
    });
  }

  void _toggleEditMode() {
    setState(() {
      widget.seriesViewMetaData.toggleEditMode();
    });
  }

  void _toggleCompressedMode() {
    setState(() {
      widget.seriesViewMetaData.toggleShowCompressed();
    });
  }

  void _toggleShowDateFilter() {
    setState(() {
      widget.seriesViewMetaData.toggleShowDateFilter();
      if (!widget.seriesViewMetaData.showDateFilter) widget.updateOverlays(bottomHeight: 0);
    });
  }

  void _setTableFixColumnProfile(FixColumnProfileType fixColumnProfileType) {
    setState(() {
      widget.seriesViewMetaData.tableFixColumnProfile = FixColumnProfile.resolveByType(fixColumnProfileType);
      if (!widget.seriesViewMetaData.showDateFilter) widget.updateOverlays(bottomHeight: 0);
    });
  }

  void _addSeriesValueHandler(BuildContext context) async {
    await SeriesData.showSeriesDataInputDlg(context, widget.seriesViewMetaData.seriesDef);
    setState(() {});
  }

  void _showSeriesDataAnalytics(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: SeriesDataAnalyticsView(
            seriesViewMetaData: widget.seriesViewMetaData,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    NavigationItem navItem = SeriesDataScreen.navItem;

    var title = _buildAbbBarTitle(themeData, navItem);
    var metaData = widget.seriesViewMetaData;
    var seriesType = metaData.seriesDef.seriesType;
    var viewType = metaData.viewType;
    var hasNoData = SeriesDataNoData.isNoData(widget.seriesDataValues);

    Widget view;
    if (hasNoData) {
      view = Column(
        children: [
          SeriesTitle(seriesViewMetaData: widget.seriesViewMetaData),
          Expanded(child: SeriesDataNoData(seriesViewMetaData: metaData)),
        ],
      );
    } else {
      view = SeriesDataView(
        seriesViewMetaData: widget.seriesViewMetaData,
        seriesDataValues: widget.seriesDataValues,
        seriesDataViewContentBuilder: widget.seriesDataViewBuilder,
        filter: widget.filter,
        updateFilter: widget.updateFilter,
        seriesDataViewOverlays: widget.seriesDataViewOverlays,
        updateOverlays: widget.updateOverlays,
      );
    }

    List<Widget> actions = [];
    // in case of portrait show actions as own bar in the bottom
    List<Widget> bottomBarActions = [];

    List<Widget> dataActions = [];
    List<Widget> viewActions = [];
    List<Widget> orientationDependentViewActions = [];

    // for all views analysis dialog
    {
      bool analyticsPossible = !hasNoData;
      if (analyticsPossible) {
        var d1 = widget.seriesDataValues.first.dateTime;
        var d2 = widget.seriesDataValues.last.dateTime;
        analyticsPossible = d1.year != d2.year || d1.month != d2.month || d1.day != d2.day;
      }
      orientationDependentViewActions.add(
        IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: LocaleKeys.seriesData_action_analytics_tooltip.tr(),
          onPressed: analyticsPossible ? () => _showSeriesDataAnalytics(context) : null,
          icon: const Icon(Icons.analytics_outlined),
        ),
      );
      orientationDependentViewActions.add(const AppBarActionsDivider());
    }

    // in table add edit-mode
    if (viewType == ViewType.table) {
      var editMode = metaData.editMode;
      dataActions.add(
        IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: editMode ? LocaleKeys.seriesData_action_editMode_disable_tooltip.tr() : LocaleKeys.seriesData_action_editMode_enable_tooltip.tr(),
          onPressed: hasNoData ? null : () => _toggleEditMode(),
          icon: Icon(editMode ? Icons.edit_off_outlined : Icons.edit_outlined),
        ),
      );
    }

    // in charts add depending on series type switch interval (day/month/year) btn
    if (viewType == ViewType.lineChart || viewType == ViewType.barChart) {
      if (/*seriesType == SeriesType.monthly ||*/ seriesType == SeriesType.dailyCheck || seriesType == SeriesType.habit) {
        var showCompressed = metaData.showCompressed;
        // monthly | yearly
        var tooltip =
            showCompressed ? LocaleKeys.seriesData_action_compression_monthly_tooltip.tr() : LocaleKeys.seriesData_action_compression_yearly_tooltip.tr();
        if (seriesType == SeriesType.habit) {
          // daily | monthly
          tooltip =
              showCompressed ? LocaleKeys.seriesData_action_compression_daily_tooltip.tr() : LocaleKeys.seriesData_action_compression_monthly_tooltip.tr();
        }

        var iconButtonToggleCompressed = IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: tooltip,
          onPressed: hasNoData ? null : () => _toggleCompressedMode(),
          icon: Icon(showCompressed ? Icons.calendar_month_outlined : Icons.calendar_today_outlined),
        );
        orientationDependentViewActions.add(iconButtonToggleCompressed);
      }
    }

    // in table view some series support multiple column profiles
    if (viewType == ViewType.table && seriesType.tableFixColumnProfileTypes.length > 1) {
      var columnProfileSelect = _SelectColumnProfile(metaData, _setTableFixColumnProfile);
      orientationDependentViewActions.add(columnProfileSelect);
    }

    // date filter - so far all views support date filter
    {
      var showDateFilter = metaData.showDateFilter;
      bool dateFilterPossible = !hasNoData;
      if (dateFilterPossible) {
        var d1 = widget.seriesDataValues.first.dateTime;
        var d2 = widget.seriesDataValues.last.dateTime;
        dateFilterPossible = d1.year != d2.year || d1.month != d2.month || d1.day != d2.day;
      }
      if (!dateFilterPossible && showDateFilter) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _toggleShowDateFilter());
      }
      String? tooltip = showDateFilter
          ? LocaleKeys.seriesData_action_filter_hide_tooltip.tr()
          : LocaleKeys.seriesData_action_filter_show_tooltip.tr(args: [widget.filter.toString()]);
      // if (!dateFilterPossible) tooltip = null;
      var iconButtonToggleShowDateFilter = IconButton(
        iconSize: ThemeUtils.iconSizeScaled,
        tooltip: tooltip,
        onPressed: dateFilterPossible ? () => _toggleShowDateFilter() : null,
        icon: SizedBox(
          height: ThemeUtils.iconSizeScaled,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -4,
                right: -2,
                child: Icon(Icons.filter_list_outlined, size: ThemeUtils.iconSizeScaled),
              ),
              Positioned(
                left: 0,
                bottom: -2,
                child: Icon(showDateFilter ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 14 * MediaQueryUtils.iconScaleFactor),
              ),
            ],
          ),
        ),
      );
      orientationDependentViewActions.add(iconButtonToggleShowDateFilter);
    }

    // depending on orientation add dependent actions
    if (_isLandscapeMode) {
      viewActions.addAll(orientationDependentViewActions);
    } else {
      bottomBarActions.addAll(orientationDependentViewActions);
    }

    dataActions.add(
      // add value btn
      IconButton(
        iconSize: ThemeUtils.iconSizeScaled,
        tooltip: LocaleKeys.seriesData_action_addValue_tooltip.tr(),
        onPressed: () => _addSeriesValueHandler(context),
        icon: const Icon(Icons.add),
      ),
    );

    // more then one view type? Add view type selection
    if (seriesType.viewTypes.length > 1) {
      viewActions.add(
        Tooltip(
          message: LocaleKeys.seriesData_action_viewTypeMenu_tooltip.tr(),
          child: IconPopupMenu(
            icon: const Icon(Icons.remove_red_eye_outlined),
            menuEntries: [
              ...seriesType.viewTypes.where((vt) => vt != viewType).map(
                    (vt) => IconPopupMenuEntry(Icon(vt.iconData), () => _setViewType(vt), vt.displayName()),
                  ),
            ],
          ),
        ),
      );
    }

    // Divider necessary?
    if (viewActions.isNotEmpty && dataActions.isNotEmpty) dataActions.add(const AppBarActionsDivider());

    actions = [
      ...dataActions,
      ...viewActions,
      const SizedBox(width: ThemeUtils.defaultPadding),
    ];

    // show bottom actions bar?
    if (bottomBarActions.isNotEmpty) {
      view = Column(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: view),
          Container(
            decoration: AppBottomNavigationBar.buildBottomNavigationBarDecoration(context),
            height: kBottomNavigationBarHeight,
            child: Material(
              // color: themeData.bottomNavigationBarTheme.backgroundColor,
              color: Colors.transparent,
              child: HCenteredScrollView(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: bottomBarActions,
              ),
            ),
          )
        ],
      );
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: title, actions: actions),
      bodyBuilder: (context) => view,
      hideBottomNavigationBar: true,
    );
  }

  Widget _buildAbbBarTitle(ThemeData themeData, NavigationItem navItem) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < ThemeUtils.iconSizeScaled) {
          return const SizedBox();
        }
        var viewType = widget.seriesViewMetaData.viewType;
        if (constraints.maxWidth < 55) {
          return Icon(
            viewType.iconData,
            color: themeData.colorScheme.onPrimary,
            size: ThemeUtils.iconSizeScaled,
          );
        }
        return Row(
          spacing: ThemeUtils.horizontalSpacing,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              viewType.iconData,
              color: themeData.colorScheme.onPrimary,
              size: ThemeUtils.iconSizeScaled,
            ),
            OverflowText(ViewType.displayNameOf(viewType)),
          ],
        );
      },
    );
  }
}

class _SeriesDefLoader extends StatelessWidget {
  const _SeriesDefLoader({required this.seriesUuid, this.seriesDef, required this.builder});

  final String seriesUuid;

  final SeriesDef? seriesDef;
  final Widget Function(SeriesViewMetaData? seriesViewMetaData) builder;

  @override
  Widget build(BuildContext context) {
    SeriesDef? loaded = seriesDef ?? context.read<SeriesProvider>().getSeries(seriesUuid);

    SeriesViewMetaData? seriesViewMetaData;
    if (loaded != null) {
      seriesViewMetaData = SeriesViewMetaData(seriesDef: loaded);
    }

    return builder(seriesViewMetaData);
  }
}

class _SelectColumnProfile extends StatelessWidget {
  const _SelectColumnProfile(this.seriesViewMetaData, this._setTableFixColumnProfile);

  final SeriesViewMetaData seriesViewMetaData;
  final Function(FixColumnProfileType fixColumnProfileType) _setTableFixColumnProfile;

  Future<void> _openMenu(BuildContext context, RenderBox overlay, Offset position) async {
    var initialValue = seriesViewMetaData.tableFixColumnProfile?.type;
    var seriesType = seriesViewMetaData.seriesDef.seriesType;

    await showMenu<FixColumnProfileType>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        ...seriesType.tableFixColumnProfileTypes.map(
          (type) => PopupMenuItem(
            onTap: () => _setTableFixColumnProfile(type),
            child: Row(
              spacing: ThemeUtils.horizontalSpacing,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                OverflowText(type.displayName),
                if (type == initialValue)
                  Icon(
                    Icons.check,
                    size: ThemeUtils.iconSizeScaled,
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: LocaleKeys.seriesData_action_selectColumnProfile_tooltip.tr(),
      icon: const Icon(Icons.view_column_outlined),
      iconSize: ThemeUtils.iconSizeScaled,
      onPressed: () async {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay);
        await _openMenu(context, overlay, position);
      },
    );
  }
}

/// Wraps an Instance of SeriesDataFilter
class _SeriesDataFilterWrapper extends StatefulWidget {
  const _SeriesDataFilterWrapper({required this.builder, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;
  final Widget Function(SeriesDataFilter filter, VoidCallback updateFilter) builder;

  @override
  State<_SeriesDataFilterWrapper> createState() => _SeriesDataFilterWrapperState();
}

class _SeriesDataFilterWrapperState extends State<_SeriesDataFilterWrapper> {
  SeriesDataFilter filter = SeriesDataFilter();

  @override
  void initState() {
    var filterStart = DateTimeUtils.firstDayOfMonth(DateTime.now().subtract(const Duration(days: 365)));
    var seriesData = context.read<SeriesDataProvider>().seriesData(widget.seriesViewMetaData.seriesDef);
    if (seriesData != null && !seriesData.isEmpty()) {
      var firstValueDateTime = seriesData.data.first.dateTime;
      if (firstValueDateTime.isAfter(filterStart)) {
        filterStart = DateTimeUtils.truncateToDay(firstValueDateTime);
      }
    }
    filter.start = filterStart;
    super.initState();
  }

  void updateFilter() {
    if (filter.getAndResetDirty()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(filter, updateFilter);
  }
}

/// Wraps an Instance of SeriesDataFilter
class _SeriesDataViewOverlaysWrapper extends StatefulWidget {
  const _SeriesDataViewOverlaysWrapper({required this.builder});

  final Widget Function(SeriesDataViewOverlays seriesDataViewOverlays, void Function({double? topHeight, double? bottomHeight}) updateOverlays) builder;

  @override
  State<_SeriesDataViewOverlaysWrapper> createState() => _SeriesDataViewOverlaysWrapperState();
}

class _SeriesDataViewOverlaysWrapperState extends State<_SeriesDataViewOverlaysWrapper> {
  SeriesDataViewOverlays seriesDataViewOverlays = SeriesDataViewOverlays(topHeight: SeriesTitle.seriesTitleHeight);

  void updateOverlays({double? topHeight, double? bottomHeight}) {
    if (seriesDataViewOverlays.setTopHeight(topHeight) || seriesDataViewOverlays.setBottomHeight(bottomHeight)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(seriesDataViewOverlays, updateOverlays);
  }
}
