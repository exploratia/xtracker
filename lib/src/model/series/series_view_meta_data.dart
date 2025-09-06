import 'series_def.dart';
import 'view_type.dart';

class SeriesViewMetaData {
  final SeriesDef seriesDef;
  late ViewType viewType;
  bool editMode = false;
  bool showCompressed = false;
  bool showDateFilter = false;

  SeriesViewMetaData({required this.seriesDef}) {
    viewType = seriesDef.seriesType.viewTypes.last;
  }

  void toggleEditMode() => editMode = !editMode;

  void toggleShowCompressed() => showCompressed = !showCompressed;

  void toggleShowDateFilter() => showDateFilter = !showDateFilter;

  @override
  String toString() {
    return 'SeriesViewMetaData{seriesDef: $seriesDef, viewType: $viewType, editMode: $editMode, showCompressed: $showCompressed, showDateFilter: $showDateFilter}';
  }
}
