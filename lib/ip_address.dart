import 'package:http/http.dart' as http;

class IPAddress {
  ///Function that return the ip address
  static Future<String> getAddress() async {
    try {
      final url = Uri.parse('https://api.ipify.org/');
      final response = await http.get(url);
      return response.statusCode == 200 ? response.body : null;
    } catch (e) {
      return null;
    }
  }

  /// Function that gets the path to the database child
  /// Returns the path
  static Future<String> getPath() async {
    String ipAddress = await getAddress();

    String child = 'users/';

    if (ipAddress != null) {
      for (int index = 0; index < ipAddress.length; index++) {
        if (ipAddress[index] == '.') {
          ipAddress = ipAddress.substring(0, index) +
              '-' +
              ipAddress.substring(index + 1);
        }
      }
      child += ipAddress;
      child += '/object';
      return child;
    } else {
      return null;
    }
  }
}
