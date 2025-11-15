import '../../../util/json_reader.dart';
import '../data/series_data_value.dart';
import '../series_type.dart';

class SeriesCurrentValue {
  final String seriesDefUuid;
  final SeriesType seriesType;

  final SeriesDataValue seriesDataValue;

  SeriesCurrentValue(this.seriesDefUuid, this.seriesType, this.seriesDataValue);

  factory SeriesCurrentValue.fromJson(JsonReader json) {
    SeriesType seriesType;
    var jType = json.at('seriesType');
    try {
      seriesType = SeriesType.byTypeName(jType.getString());
    } catch (err) {
      throw JsonParseException('Invalid value at ${jType.pathString} - $err');
    }

    return SeriesCurrentValue(
      json.at('seriesDefUuid').getString(),
      seriesType,
      SeriesDataValue.fromJson(
        json.at('seriesDataValue'),
        seriesType,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'seriesDefUuid': seriesDefUuid,
        'seriesType': seriesType.typeName,
        'seriesDataValue': seriesDataValue.toJson(),
      };
}
