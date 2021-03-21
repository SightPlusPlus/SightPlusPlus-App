/// Model class for records
class Record {
  final String object;
  final String date;
  final String time;
  final String location;
  final String error;
  final String remote;

  Record(
      {this.object,
      this.time,
      this.date,
      this.location,
      this.error,
      this.remote});

  Map<String, dynamic> toMap() {
    return {
      'object': object,
      'time': time,
      'date': date,
      'location': location,
      'error': error,
      'remote': remote,
    };
  }
}
