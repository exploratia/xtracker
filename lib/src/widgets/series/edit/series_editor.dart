import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../model/series/settings/custom/custom_tags_settings.dart';
import '../../../model/series/settings/daily_life/daily_life_tags_settings.dart';
import '../../../model/series/settings/notification_settings.dart';
import '../../../providers/series_provider.dart';
import '../../../util/app_icon_quick_actions.dart';
import '../../../util/app_series_notifications.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/theme_utils.dart';
import '../../controls/appbar/gradient_app_bar.dart';
import '../../controls/card/expandable.dart';
import '../../controls/form/validation_field.dart';
import '../../controls/layout/scrollable_centered_form_wrapper.dart';
import '../../controls/select/color_picker.dart';
import '../../controls/select/icon_map.dart';
import '../../controls/select/icon_picker.dart';
import '../../controls/text/overflow_text.dart';
import 'blood_pressure/blood_pressure_series_edit.dart';
import 'custom/custom_series_edit_tags.dart';
import 'daily_life/daily_life_series_edit_tags.dart';
import 'series_edit_display_settings.dart';
import 'series_edit_notification_settings.dart';
import 'series_items/series_items_edit.dart';

class SeriesEditor extends StatefulWidget {
  const SeriesEditor({super.key, required this.seriesDef, required this.goBack});

  final SeriesDef seriesDef;
  final Function()? goBack;

  @override
  State<SeriesEditor> createState() => _SeriesEditorState();
}

class _SeriesEditorState extends State<SeriesEditor> {
  static const _maxSystemQuickActions = 4;
  late SeriesDef _seriesDef;

  late DailyLifeTagsSettings? _dailyLifeTagsSettings;
  late CustomTagsSettings? _customTagsSettings;

  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;
  bool _quickActionEnabled = false;

  @override
  void initState() {
    // when loading series into the editor ignore invalid once (e.g. new DailyLife without tags)
    _seriesDef = widget.seriesDef.clone(ignoreValidation: true);
    var seriesType = _seriesDef.seriesType;

    _nameController.addListener(_validate);
    _nameController.text = _seriesDef.name.toString();

    _dailyLifeTagsSettings = (seriesType != SeriesType.dailyLife) ? null : _seriesDef.dailyLifeTagsSettingsEditable(_updateState);
    _customTagsSettings = ([SeriesType.custom, SeriesType.monthly].contains(seriesType)) ? _seriesDef.customTagsSettingsEditable(_updateState) : null;
    _quickActionEnabled = _seriesDef.quickActionsSettingsReadonly().showAddValueInAppContextMenu;

    if (widget.goBack == null) {
      _isValid = true;
      _autoValidate = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _updateState() {
    setState(() {});
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid) _formKey.currentState?.save();
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  Future<void> _saveHandler() async {
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;

    _setLoading(true);

    try {
      var notificationSettings = _seriesDef.notificationSettingsReadonly();
      if (notificationSettings.enabled &&
          notificationSettings.repeatType == NotificationRepeatType.everyXDays &&
          notificationSettings.everyXDaysAnchorUtcMs == null) {
        var now = DateTime.now();
        _seriesDef.notificationSettingsEditable(_updateState).everyXDaysAnchorUtcMs = DateTime(now.year, now.month, now.day).toUtc().millisecondsSinceEpoch;
      }

      var notificationEnabledBeforeSave = widget.seriesDef.notificationSettingsReadonly().enabled;
      if (!notificationEnabledBeforeSave && notificationSettings.enabled && AppSeriesNotifications.isSchedulingSupportedOnCurrentPlatform) {
        var permissionGranted = await AppSeriesNotifications.ensurePermissionRequested();
        if (!permissionGranted) {
          _seriesDef.notificationSettingsEditable(_updateState).enabled = false;
          if (mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.seriesEdit_seriesSettings_notifications_alert_permissionDenied.tr(), context);
          }
          _setLoading(false);
          return;
        }
      }
      if (!mounted) return;

      var seriesProvider = context.read<SeriesProvider>();
      var quickActionsChanged = await AppIconQuickActions.setSeriesQuickActionEnabled(_seriesDef, _quickActionEnabled);
      await seriesProvider.save(_seriesDef);
      if (quickActionsChanged) {
        await AppIconQuickActions.refreshSeriesShortcutItems(seriesProvider.series);
        await _showQuickActionsSystemLimitInfoIfNeeded(seriesProvider.series);
      }
      if (mounted) {
        Dialogs.showSnackBar(LocaleKeys.commons_snackbar_saveSuccess.tr(), context);
      }
    } catch (err) {
      SimpleLogging.w('Failed to store series.', error: err);
      if (mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_saveFailed.tr(), context);
      }
      _setLoading(false);
      return;
    }

    _setLoading(false);

    if (mounted) Navigator.of(context).pop(_seriesDef);
  }

  Future<void> _showQuickActionsSystemLimitInfoIfNeeded(List<SeriesDef> allSeries) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    var enabledSeriesIds = await AppIconQuickActions.readEnabledSeriesQuickActions(allSeries);
    if (enabledSeriesIds.length <= _maxSystemQuickActions || !mounted) {
      return;
    }

    var configuredSeriesNames = allSeries
        .where((seriesDef) => enabledSeriesIds.contains(seriesDef.uuid))
        .map((seriesDef) => seriesDef.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (configuredSeriesNames.isEmpty) {
      return;
    }

    var listItems = configuredSeriesNames.map((name) => '- $name').join('\n');
    var message = [
      LocaleKeys.seriesEdit_seriesSettings_quickActions_alert_androidSystemLimit_message.tr(args: ['$_maxSystemQuickActions']),
      '',
      LocaleKeys.seriesEdit_seriesSettings_quickActions_alert_androidSystemLimit_configuredSeries.tr(),
      listItems,
    ].join('\n');

    await Dialogs.simpleOkDialog(
      message,
      context,
      title: LocaleKeys.seriesEdit_seriesSettings_quickActions_alert_androidSystemLimit_title.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _Loading();

    var formWrapper = ScrollableCenteredFormWrapper(
      formKey: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      children: [
        // is new - then go back is allowed
        if (widget.goBack != null)
          Row(
            children: [
              IconButton(
                iconSize: ThemeUtils.iconSizeScaled,
                tooltip: LocaleKeys.seriesEdit_btn_backToSeriesTypeSelection.tr(),
                onPressed: widget.goBack,
                icon: const Icon(Icons.arrow_back_outlined),
              ),
            ],
          ),
        _SeriesTypeHeadline(seriesDef: _seriesDef),
        const Divider(),
        // series name:
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: InputDecoration(
            labelText: LocaleKeys.seriesEdit_common_label_seriesName.tr(),
            hintText: _seriesDef.seriesType.displayName,
          ),
          textInputAction: TextInputAction.next,
          // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.commons_validator_emptyValue.tr();
            }
            return null;
          },
          onChanged: (value) {
            _seriesDef.name = value.trim();
          },
        ),
        const SizedBox(height: ThemeUtils.verticalSpacing),
        _SeriesSymbolAndColor(_seriesDef, _updateState),

        // series type dependent...
        if (_seriesDef.seriesType == SeriesType.custom || _seriesDef.seriesType == SeriesType.monthly)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expandable(
                initialExpanded: true,
                useVerticalSpacingBeforeChild: false /* ListView has own padding */,
                icon: Icon(Icons.format_list_numbered_outlined, size: ThemeUtils.iconSizeScaled),
                title: LocaleKeys.seriesEdit_seriesSettings_seriesItems_title.tr(),
                child: SeriesItemsEdit(_seriesDef, _updateState),
              ),
              ValidationField(
                validatorCondition: () => _seriesDef.seriesItems.isNotEmpty,
                errorMessage: LocaleKeys.seriesEdit_seriesSettings_seriesItems_validation_emptyParameters.tr(),
              ),
              ValidationField(
                validatorCondition: () => _seriesDef.seriesItems.isEmpty || _seriesDef.seriesItems.where((e) => !e.hideInTable).isNotEmpty,
                errorMessage: LocaleKeys.seriesEdit_seriesSettings_seriesItems_validation_emptyParametersTable.tr(),
              ),
              ValidationField(
                validatorCondition: () => _seriesDef.seriesItems.isEmpty || _seriesDef.seriesItems.where((e) => !e.hideInChart).isNotEmpty,
                errorMessage: LocaleKeys.seriesEdit_seriesSettings_seriesItems_validation_emptyParametersChart.tr(),
              ),
            ],
          ),

        // if (_seriesDef.seriesType == SeriesType.custom)
        //   Expandable(
        //     initialExpanded: false,
        //     icon: Icon(Icons.line_axis_outlined, size: ThemeUtils.iconSizeScaled),
        //     title: LocaleKeys.seriesEdit_seriesSettings_custom_title.tr(),
        //     child: CustomSeriesEdit(_seriesDef, _updateState),
        //   ),
        if (_seriesDef.seriesType == SeriesType.bloodPressure)
          Expandable(
            initialExpanded: true,
            icon: Icon(Icons.monitor_heart_outlined, size: ThemeUtils.iconSizeScaled),
            title: LocaleKeys.seriesEdit_seriesSettings_bloodPressure_title.tr(),
            child: BloodPressureSeriesEdit(_seriesDef, _updateState),
          ),

        if (_dailyLifeTagsSettings != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expandable(
                initialExpanded: true,
                useVerticalSpacingBeforeChild: false /* ListView has own padding */,
                icon: Icon(Icons.format_list_bulleted_outlined, size: ThemeUtils.iconSizeScaled),
                title: LocaleKeys.seriesEdit_seriesSettings_tags_title.tr(),
                child: DailyLifeSeriesEditTags(_seriesDef, _dailyLifeTagsSettings!),
              ),
              ValidationField(
                validatorCondition: () => _dailyLifeTagsSettings!.isValid(),
                errorMessage: LocaleKeys.seriesEdit_seriesSettings_tags_validation_emptyTags.tr(),
              ),
            ],
          ),

        if (_customTagsSettings != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expandable(
                initialExpanded: false,
                useVerticalSpacingBeforeChild: false /* ListView has own padding */,
                icon: Icon(Icons.format_list_bulleted_outlined, size: ThemeUtils.iconSizeScaled),
                title: LocaleKeys.seriesEdit_seriesSettings_tags_title.tr(),
                child: CustomSeriesEditTags(_seriesDef, _customTagsSettings!),
              ),
              ValidationField(
                validatorCondition: () => _customTagsSettings!.isValid(),
                errorMessage: "unexpected custom tag validation",
              ),
            ],
          ),

        // only show DisplaySettings if there is something for that series type
        if (SeriesEditDisplaySettings.applicableOn(_seriesDef)) SeriesEditDisplaySettings(_seriesDef, _updateState),

        // Notification
        SeriesEditNotificationSettings(_seriesDef, _updateState),

        Expandable(
          initialExpanded: false,
          icon: Icon(Icons.touch_app_outlined, size: ThemeUtils.iconSizeScaled),
          title: LocaleKeys.seriesEdit_seriesSettings_quickActions_title.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(LocaleKeys.seriesEdit_seriesSettings_quickActions_label_showAddValueInAppContextMenu.tr()),
                value: _quickActionEnabled,
                onChanged: (value) {
                  setState(() {
                    _quickActionEnabled = value;
                  });
                },
                secondary: Icon(Icons.add_outlined, size: ThemeUtils.iconSizeScaled),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(LocaleKeys.seriesEdit_title.tr()),
        leading: IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: LocaleKeys.seriesEdit_action_abort_tooltip.tr(),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_outlined),
        ),
        actions: [
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_action_save_tooltip.tr(),
            onPressed: _saveHandler,
            icon: const Icon(Icons.save_outlined),
          ),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
      body: formWrapper,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(LocaleKeys.seriesEdit_title.tr()),
      ),
      body: const LinearProgressIndicator(),
    );
  }
}

class _SeriesTypeHeadline extends StatelessWidget {
  const _SeriesTypeHeadline({required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      spacing: ThemeUtils.horizontalSpacing,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconMap.icon(seriesDef.iconName, seriesDef.seriesType.iconData, size: ThemeUtils.iconSizeScaled),
        OverflowText(
          seriesDef.seriesType.displayName,
          style: themeData.textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _SeriesSymbolAndColor extends StatelessWidget {
  const _SeriesSymbolAndColor(this.seriesDef, this.updateStateCB);

  final SeriesDef seriesDef;
  final Function() updateStateCB;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.spaceAround,
      spacing: 40,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: ThemeUtils.horizontalSpacing,
          children: [
            Text(LocaleKeys.seriesEdit_common_label_seriesIcon.tr()),
            IconPicker(
              icoName: seriesDef.iconName ?? IconMap.resolveNameByIconData(seriesDef.seriesType.iconData),
              icoSelected: (icoName) {
                seriesDef.iconName = icoName;
                updateStateCB();
              },
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: ThemeUtils.horizontalSpacing,
          children: [
            Text(LocaleKeys.seriesEdit_common_label_seriesColor.tr()),
            ColorPicker(
              color: seriesDef.color,
              colorSelected: (color) {
                seriesDef.color = color;
                updateStateCB();
              },
            ),
          ],
        ),
      ],
    );
  }
}
