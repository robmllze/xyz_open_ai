import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//  curl -N http://localhost:8081/chat
void main() {
  HttpServer.bind(InternetAddress.loopbackIPv4, 8081).then((server) {
    print("HTTP Server listening on port ${server.port}");
    server.listen((HttpRequest request) async {
      if (request.uri.path == '/chat') {
        await handleChat(request);
      } else {
        // handle other paths...
      }
    });
  });
}

Future<void> handleChat(HttpRequest request) async {
  var response = request.response;
  response.headers.add('Content-Type', 'text/event-stream');
  response.headers.add('Cache-Control', 'no-cache');
  response.bufferOutput = false; // Disable buffering

  try {
    var apiKey =
        "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"; // Securely retrieve your API key
    var uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Using default values for testing
    var messages = [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Tell me a funny story."}
    ];
    var model = 'gpt-3.5-turbo-0301';
    var maxTokens = 500;
    var temperature = 0.5;

    var requestOptions = {
      'model': model,
      'temperature': temperature,
      'messages': messages,
      'max_tokens': maxTokens,
      'stream': true,
      'stop': '[DONE]',
    };

    var client = http.Client();
    var request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      })
      ..body = json.encode(requestOptions);

    var streamedResponse = await client.send(request);

    // Stream the response
    await for (var data in streamedResponse.stream.transform(utf8.decoder)) {}

    await response.close();
  } catch (e) {
    response.statusCode = HttpStatus.internalServerError;
    await response.close();
  }
}
