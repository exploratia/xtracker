import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/daily_check/daily_check_value.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../providers/series_data_provider.dart';
import '../../screens/series/series_data_screen.dart';

class SeriesActions extends StatelessWidget {
  const SeriesActions({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          seriesDef.seriesType == SeriesType.dailyCheck ? _DailyCheckBtn(seriesDef: seriesDef) : _ShowSeriesDataInputDlgBtn(seriesDef: seriesDef),
          _ShowSeriesDataBtn(seriesDef: seriesDef),
        ],
      ),
    );
  }
}

class _ShowSeriesDataBtn extends StatelessWidget {
  const _ShowSeriesDataBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    showDataHandler() async {
      await Navigator.pushNamed(context, SeriesDataScreen.navItem.routeName, arguments: {'series': seriesDef});
    }

    return IconButton(
      tooltip: LocaleKeys.seriesDefRenderer_action_showSeriesValues_tooltip.tr(),
      onPressed: showDataHandler,
      icon: const Icon(Icons.remove_red_eye_outlined),
    );
  }
}

class _ShowSeriesDataInputDlgBtn extends StatelessWidget {
  const _ShowSeriesDataInputDlgBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: LocaleKeys.seriesDefRenderer_action_addValue_tooltip.tr(),
      onPressed: () => SeriesData.showSeriesDataInputDlg(context, seriesDef),
      icon: const Icon(Icons.add),
    );
  }
}

class _DailyCheckBtn extends StatelessWidget {
  const _DailyCheckBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: LocaleKeys.seriesDefRenderer_action_addValue_tooltip.tr(),
        onPressed: () {
          context.read<SeriesDataProvider>().addValue(seriesDef, DailyCheckValue(const Uuid().v4(), DateTime.now()), context);
        },
        icon: const Icon(Icons.check_outlined));
  }
}
