part of cough_detection;

enum CoughType { DRY, PRODUCTIVE }

Map<String, CoughType> dict = {
  CoughType.DRY.toString(): CoughType.DRY,
  CoughType.PRODUCTIVE.toString(): CoughType.PRODUCTIVE
};

class Cough {
  DateTime _date;
  CoughType _coughType;

  Cough(this._date, this._coughType);

  DateTime get date => _date;

  CoughType get coughType => _coughType;

  Map<String, dynamic> toJson() => {
    'date': this._date.toIso8601String(),
    'cough_type': this._coughType.toString()
  };

  factory Cough.fromJson(Map<String, dynamic> jsonObj) {
    return Cough(DateTime.parse(jsonObj['date']), dict[jsonObj['cough_type']]);
  }

  @override
  String toString() => 'Cough on date $date ($coughType)';
}
