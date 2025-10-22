import '../../../../../../model/series/data/monthly/monthly_value.dart';
import '../../free/table/series_data_multi_value_table_view.dart';

class SeriesDataMonthlyTableView extends SeriesDataMultiValueTableView<MonthlyValue> {
  const SeriesDataMonthlyTableView(
      {super.key, required super.seriesViewMetaData, required super.seriesData, required super.seriesDataFilter, required super.seriesDataViewOverlays});
}
