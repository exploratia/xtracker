import 'series_def.dart';
import 'view_type.dart';

class SeriesViewMetaData {
  final SeriesDef seriesDef;
  final ViewType viewType;
  final bool editMode;
  final bool showYearly;

  SeriesViewMetaData({
    required this.seriesDef,
    required this.viewType,
    required this.editMode,
    required this.showYearly,
  });
}
