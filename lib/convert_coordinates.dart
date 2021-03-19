import 'package:firebase_database/firebase_database.dart';

class ConvertCoordinates {
  String oldCoordinates;

  ConvertCoordinates({this.oldCoordinates});

  List<String> convertCoordinates() {
    List<String> newCoordinates = [];
    int splitIndex;
    for (int index = 0; index < oldCoordinates.length; index++) {
      if (oldCoordinates[index] == '-') {
        oldCoordinates = oldCoordinates.substring(0, index) +
            '.' +
            oldCoordinates.substring(index + 1);
      } else if (oldCoordinates[index] == '+') {
        splitIndex = index;
      }
    }
    newCoordinates.add(oldCoordinates.substring(0, splitIndex));
    newCoordinates.add(oldCoordinates.substring(splitIndex + 1));
    return newCoordinates;
  }
}
