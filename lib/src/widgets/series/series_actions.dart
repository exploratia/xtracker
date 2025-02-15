import 'package:flutter/material.dart';

import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../screens/series/series_data_screen.dart';

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
      await Navigator.pushNamed(context, SeriesDataScreen.navItem.routeName, arguments: {'series': seriesDef.uuid});
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
    return IconButton(onPressed: () => SeriesData.showSeriesDataInputDlg(context, seriesDef), icon: const Icon(Icons.add));
  }
}
