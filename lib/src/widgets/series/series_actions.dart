import 'package:flutter/material.dart';

import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
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
          _ShowSeriesDataInputDlgBtn(seriesDef: seriesDef),
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

    return IconButton(onPressed: showDataHandler, icon: const Icon(Icons.remove_red_eye_outlined));
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
