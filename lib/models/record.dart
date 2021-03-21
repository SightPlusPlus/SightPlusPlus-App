class Record {
  final String object;
  final String date;
  final String time;
  final String location;
  final String error;

  Record({this.object, this.time, this.date, this.location, this.error});

  Map<String, dynamic> toMap() {
    return {
      'object': object,
      'time': time,
      'date': date,
      'location': location,
      'error': error,
    };
  }
}
