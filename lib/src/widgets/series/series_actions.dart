import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../screens/series/series_data_screen.dart';
import 'data/input/blood_pressure/blood_pressure_quick_input.dart';

class SeriesActions extends StatelessWidget {
  const SeriesActions({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 1,
            color: seriesDef.color,
          ),
        ),
        _ShowSeriesDataBtn(seriesDef: seriesDef),
        const SizedBox(width: 10),
        _ShowSeriesDataInputDlgBtn(seriesDef: seriesDef),
      ],
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
      await Navigator.pushNamed(context, SeriesDataScreen.navItem.routeName, arguments: seriesDef.uuid);
    }

    return IconButton(onPressed: showDataHandler, icon: const Icon(Icons.area_chart_outlined));
  }
}

class _ShowSeriesDataInputDlgBtn extends StatelessWidget {
  const _ShowSeriesDataInputDlgBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showDlgHandler() async {
      switch (seriesDef.seriesType) {
        case SeriesType.bloodPressure:
          var val = await BloodPressureQuickInput.showInputDlg(context, seriesDef);
          print(val);
        case SeriesType.dailyCheck:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SeriesType.monthly:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SeriesType.free:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    return IconButton(onPressed: showDlgHandler, icon: const Icon(Icons.add));
  }
}
