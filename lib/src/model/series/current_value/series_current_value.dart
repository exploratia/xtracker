import '../data/series_data_value.dart';
import '../series_type.dart';

class SeriesCurrentValue {
  final String seriesDefUuid;
  final SeriesType seriesType;

  final SeriesDataValue seriesDataValue;

  SeriesCurrentValue(this.seriesDefUuid, this.seriesType, this.seriesDataValue);

  factory SeriesCurrentValue.fromJson(Map<String, dynamic> json) => SeriesCurrentValue(
        json['seriesDefUuid'] as String,
        SeriesType.byTypeName(json['seriesType'] as String),
        SeriesDataValue.fromJson(
          json['seriesDataValue'] as Map<String, dynamic>,
          SeriesType.byTypeName(json['seriesType'] as String),
        ),
      );

  Map<String, dynamic> toJson() => {
        'seriesDefUuid': seriesDefUuid,
        'seriesType': seriesType.typeName,
        'seriesDataValue': seriesDataValue.toJson(),
      };
}
