import 'dart:async';
import 'dart:io';

void main() {
  var server = HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  server.then((HttpServer server) {
    print("HTTP Server listening on port ${server.port}");
    server.listen((HttpRequest request) {
      if (request.uri.path == '/count_to_10') {
        handleCountTo10(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    });
  });
}

void handleCountTo10(HttpRequest request) {
  var response = request.response;
  response.headers.add('Content-Type', 'text/event-stream');
  response.headers.add('Cache-Control', 'no-cache');
  response.headers.add('Connection', 'keep-alive');
  response.bufferOutput = false; // Disable buffering

  int count = 1;
  Timer.periodic(Duration(seconds: 1), (Timer timer) {
    if (count <= 10) {
      response.write('data: $count\n\n');
      count++;
    } else {
      timer.cancel();
      response.close();
    }
  });
}
