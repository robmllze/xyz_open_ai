// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // import the http package
import 'dart:async';
import 'dart:convert';

Future<String> getOpenAiChat({
  required String apiKey,
  required List<ModelMessage> messages,
  int worldLimit = 16000,
  String model = "gpt-3.5-turbo",
}) async {
  final mappedMessages = trimMessageHistory(messages, worldLimit)
      .map((e) => {"role": e.role, "content": e.content})
      .toList();
  final data = {
    'messages': mappedMessages,
    'model': model,
  };

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };
  final request = http.Request(
    'POST', // make a POST request
    Uri.parse(
      'https://api.openai.com/v1/chat/completions',
    ), // the OpenAI API endpoint for chat completions
  );
  request.body =
      json.encode(data); // the request body is set to a JSON-encoded version of the chat data
  request.headers.addAll(
    headers,
  ); // the headers for the request are set to include the authorization token and content type

  final httpResponse = await request.send(); // send the request

  if (httpResponse.statusCode == 200) {
    // if the response is OK
    final jsonResponse =
        json.decode(await httpResponse.stream.bytesToString()); // decode the JSON response
    final content = jsonResponse['choices'][0]['message']['content']
        .toString(); // extract the content of the response
    final modifiedText = content.replaceFirst(RegExp(r'^\s+'), '');
    return modifiedText; // return the chat content
  } else {
    // if the response is not OK
    return ""; // return an empty string
  }
}

class ModelMessage {
  String? role;
  String? id;
  String? content;
  int? timestamp;

  ModelMessage({
    this.role,
    this.id,
    this.content,
    this.timestamp,
  });

  ModelMessage.fromJson(Map<String, dynamic> json) {
    role = json["role"];
    content = json["content"];
    id = json["id"];
    final temp = json["timestamp"];
    timestamp = temp is int ? temp : 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["role"] = role;
    data["content"] = content;
    data["id"] = id;
    data["timestamp"] = timestamp;
    data.removeWhere((_, final value) => value == null);
    return data;
  }
}

List<ModelMessage> sortMessageHistory(List<ModelMessage> messages) {
  final sortedMessages = (List.of(messages)..sort((a, b) => a.timestamp!.compareTo(b.timestamp!)));
  return sortedMessages;
}

List<ModelMessage> trimMessageHistory(
  List<ModelMessage> messages,
  int worldLimit,
) {
  final sortedMessages = sortMessageHistory(messages);
  final inputMessages = <ModelMessage>[
    if (sortedMessages.isNotEmpty) sortedMessages.first,
    ...sortedMessages.length > 2
        ? sortedMessages.reversed.toList().sublist(0, sortedMessages.length - 2)
        : [],
  ].nonNulls;

  final buffer = <ModelMessage>[];
  var totalSize = 0;
  for (final message in inputMessages) {
    totalSize += message.content?.split(" ").length ?? 0;
    if (totalSize > worldLimit) {
      break;
    }
    buffer.add(message);
  }

  return sortMessageHistory(buffer);
}
