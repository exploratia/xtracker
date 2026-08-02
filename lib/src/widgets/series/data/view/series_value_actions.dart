import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../providers/series_current_value_provider.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/globals.dart';
import '../../../../util/logging/flutter_simple_logging.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/popupmenu/icon_popup_menu.dart';
import '../input/input_result.dart';

/// Adds the context actions available for one concrete series value.
class SeriesValueActions extends StatefulWidget {
  const SeriesValueActions({
    super.key,
    required this.seriesDef,
    required this.value,
    required this.childBuilder,
    this.onTap,
  });

  final SeriesDef seriesDef;
  final SeriesDataValue value;
  final Widget Function(BuildContext context, bool selected) childBuilder;
  final VoidCallback? onTap;

  @override
  State<SeriesValueActions> createState() => _SeriesValueActionsState();
}

class _SeriesValueActionsState extends State<SeriesValueActions> {
  Offset? _globalTapPosition;
  bool _menuVisible = false;

  bool get _canDuplicate => widget.seriesDef.seriesType != SeriesType.habit && widget.seriesDef.seriesType != SeriesType.dailyCheck;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: widget.onTap == null ? LocaleKeys.seriesValue_action_semanticsHintLongPress.tr() : LocaleKeys.seriesValue_action_semanticsHint.tr(),
      child: InkWell(
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        onTap: widget.onTap,
        onTapDown: (details) => _globalTapPosition = details.globalPosition,
        onLongPress: _showActions,
        child: widget.childBuilder(context, _menuVisible),
      ),
    );
  }

  Future<void> _showActions() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final position = _globalTapPosition ?? renderBox?.localToGlobal(renderBox.size.center(Offset.zero));
    if (position == null) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _menuVisible = true);
    await IconPopupMenu.showAt(
      context,
      globalPosition: position,
      layout: IconPopupMenuLayout.radial,
      menuEntries: [
        IconPopupMenuEntry(
          const Icon(Icons.edit_outlined),
          _edit,
          LocaleKeys.seriesValue_action_editValue_tooltip.tr(),
        ),
        if (_canDuplicate)
          IconPopupMenuEntry(
            const Icon(Icons.content_copy_outlined),
            _duplicate,
            LocaleKeys.seriesValue_action_duplicateValue_tooltip.tr(),
          ),
        IconPopupMenuEntry(
          const Icon(Icons.delete_outlined),
          _delete,
          LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
        ),
        if (Globals.debugShowSeriesValueActionTestButtons) ...[
          IconPopupMenuEntry(const Icon(Icons.star_outline), _dummyAction, LocaleKeys.commons_btn_info_tooltip.tr()),
          IconPopupMenuEntry(const Icon(Icons.favorite_outline), _dummyAction, LocaleKeys.commons_btn_info_tooltip.tr()),
          IconPopupMenuEntry(const Icon(Icons.share_outlined), _dummyAction, LocaleKeys.commons_btn_info_tooltip.tr()),
          IconPopupMenuEntry(const Icon(Icons.info_outline), _dummyAction, LocaleKeys.commons_btn_info_tooltip.tr()),
        ],
      ],
    );
    if (mounted) {
      setState(() => _menuVisible = false);
    }
  }

  void _dummyAction() {}

  void _edit() {
    SeriesData.showSeriesDataInputDlg(context, widget.seriesDef, value: widget.value);
  }

  void _duplicate() {
    final duplicate = widget.value.duplicateAt(DateTime.now());
    SeriesData.showSeriesDataInputDlg(
      context,
      widget.seriesDef,
      value: duplicate,
      inputMode: SeriesDataInputMode.create,
    );
  }

  Future<void> _delete() async {
    final confirmed = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesValue_query_deleteValue.tr(),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await context.read<SeriesDataProvider>().deleteValue(
        widget.seriesDef,
        widget.value,
        context.read<SeriesCurrentValueProvider>(),
      );
    } catch (error, stackTrace) {
      SimpleLogging.w(
        'Failed to delete ${widget.seriesDef.seriesType.name} value.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_deleteFailed.tr(), context);
      }
    }
  }
}
