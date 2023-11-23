//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// © 2023 Robert Mollentze
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async';
import 'dart:html';
import 'package:http/http.dart' as http;

void main() async {
  querySelector('#output')?.text = "Running...\n\n";
  final stream = streamCloudRunService(
    "https://story-yu6ys3tgxa-ts.a.run.app",
    onData: (data) {
      final a = querySelector('#output')?.text;
      final b = "${a ?? ""}$data";
      querySelector('#output')?.text = b;
      print("Streamed data: $b");
    },
  );
  await stream.asFuture();
  querySelector('#output')?.text = "${querySelector('#output')?.text}...DONE";
  await Future.delayed(Duration(seconds: 30));
  querySelector('#output')?.text = "${querySelector('#output')?.text}...WAITED";
}

StreamSubscription<dynamic> streamCloudRunService(
  String url, {
  void Function(dynamic)? onData,
  Function? onError,
  void Function()? onDone,
}) {
  // Listening for messages
  return EventSource(url).onMessage.asyncMap((e) => e.data).listen(
        onData,
        onDone: onDone,
        onError: onError,
      );
}

Future<String> callCloudRunService(String url) async {
  try {
    // Replace with your Cloud Run service URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data from Cloud Run');
    }
  } catch (e) {
    // Handle any exceptions here
    return 'Error: ${e.toString()}';
  }
}



  // final chat = open_ai_chat.OpenAiChat(
  //     apiKey: "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",
  //     endpointUrl: "https://openaichat3-yu6ys3tgxa-ts.a.run.app");
  // final response = await chat.getOpenAiChatResponse(
  //   messages: [
  //     open_ai_chat.OpenAiChatMessage(
  //       role: open_ai_chat.OpenAiChatRole.SYSTEM,
  //       content: "You are a helpful assistant",
  //     ),
  //     open_ai_chat.OpenAiChatMessage(
  //       role: open_ai_chat.OpenAiChatRole.USER,
  //       content: "What are you?",
  //     ),
  //   ],
  //   onData: (buffer, chunk) {
  //     print("Buffer: $buffer");
  //     print("Chunk: $chunk");
  //   },
  // );

