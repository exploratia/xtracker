import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../util/dialogs.dart';
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
      bool? res = await Dialogs.simpleYesNoDialog(
        'TODO show Series data', // TODO show data
        context,
      );
      if (res == true) {
        try {
          // if (context.mounted) {
          //   await context.read<SeriesProvider>().remove(seriesDef);
          // }
        } catch (err) {
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
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
      bool? res = false;
      if (seriesDef.seriesType == SeriesType.bloodPressure) {
        var val = await BloodPressureQuickInput.showInputDlg(context, seriesDef);
        print(val);
      } else {
        res = await Dialogs.simpleYesNoDialog(
          'TODO show edit dlg ${seriesDef.seriesType}', // TODO
          context,
          title: t.commonsDialogTitleAreYouSure,
        );
        if (res == true) {
          try {
            // if (context.mounted) {
            //   await context.read<SeriesProvider>().remove(seriesDef);
            // }
          } catch (err) {
            if (context.mounted) {
              Dialogs.simpleErrOkDialog('$err', context);
            }
          }
        }
      }
    }

    return IconButton(onPressed: showDlgHandler, icon: const Icon(Icons.add));
  }
}
