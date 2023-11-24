//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ AI
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async';
import 'dart:io';

import 'package:xyz_open_ai/utils/general.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main(List<String> args) async {
  final port = int.tryParse(args.firstOrNull ?? "8080") ?? 8080;
  final httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print("[HTTP Server] Listening: $port...");
  httpServer.listen((final request) {
    final path = request.uri.path;
    switch (path) {
      case "/count_to_10":
        handleCountTo10Request(request);
        break;
      default:
        handleInvalidRequest(request);
    }
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void handleInvalidRequest(HttpRequest request) {
  final response = request.response;
  final path = request.uri.path;
  response
    ..statusCode = HttpStatus.notFound
    ..write("Invalid request: $path")
    ..close();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> handleCountTo10Request(HttpRequest request) async {
  final response = request.response;
  response.headers.add("Content-Type", "text/event-stream");
  response.headers.add("Cache-Control", "no-cache");
  response.headers.add("Connection", "keep-alive");
  response.bufferOutput = false;
  final completer = Completer<void>();
  var count = 1;
  Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    if (count <= 10) {
      response.write(toServerData(count));
      count++;
    } else {
      timer.cancel();
      response.close();
      completer.complete();
    }
  });
}
