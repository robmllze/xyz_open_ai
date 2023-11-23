import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  var url = Uri.parse('http://localhost:8080/count_to_10');
  var client = http.Client();
  try {
    var request = http.Request('GET', url);
    var response = await client.send(request);

    response.stream.transform(const Utf8Decoder()).transform(const LineSplitter()).listen((data) {
      print(data);
    }, onDone: () {
      client.close();
    }, onError: (e) {
      print(e);
      client.close();
    });
  } catch (e) {
    print('Error: $e');
    client.close();
  }
}
