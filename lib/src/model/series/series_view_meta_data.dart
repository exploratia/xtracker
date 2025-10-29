import '../column_profile/column_profile.dart';
import '../column_profile/fix_column_profile.dart';
import 'series_def.dart';
import 'view_type.dart';

class SeriesViewMetaData {
  final SeriesDef seriesDef;
  late ViewType viewType;
  bool editMode = false;
  bool showCompressed = false;
  bool showDateFilter = false;
  ColumnProfile? columnProfile;

  SeriesViewMetaData({required this.seriesDef}) {
    viewType = seriesDef.determineViewType;
    columnProfile = seriesDef.determineTableColumnProfile;
  }

  /// returns the column profile if it is a fixed one
  FixColumnProfile? get tableFixColumnProfile {
    if (columnProfile is FixColumnProfile) {
      return columnProfile as FixColumnProfile;
    }
    return null;
  }

  void toggleEditMode() => editMode = !editMode;

  void toggleShowCompressed() => showCompressed = !showCompressed;

  void toggleShowDateFilter() => showDateFilter = !showDateFilter;

  @override
  String toString() {
    return 'SeriesViewMetaData{seriesDef: $seriesDef, viewType: $viewType, editMode: $editMode, showCompressed: $showCompressed, showDateFilter: $showDateFilter}';
  }
}
