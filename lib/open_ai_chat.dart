//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// © 2023 Robert Mollentze
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter, constant_identifier_names, unnecessary_this

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xyz_open_ai/open_ai_chat_role.dart';

import 'open_ai_gpt_model.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class OpenAiChat {
  //
  //
  //

  final String apiKey;

  //
  //
  //

  OpenAiChat({required this.apiKey});

  //
  //
  //

  Stream<String> getOpenAiChatCompletionStream({
    required List<OpenAiChatMessage> messages,
    int maxTokens = 2000,
    OpenAiGptModel model = OpenAiGptModels.gpt3_5_turbo_16k,
    double temperature = 0.7,
    void Function(String buffer)? onData,
  }) async* {
    assert(messages.isNotEmpty);
    assert(maxTokens > 0 && maxTokens <= model.maxTokens);
    assert(temperature > 0 && temperature <= 2.0);
    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    var requestOptions = {
      "model": model.name,
      "temperature": temperature,
      "messages": messages.map((e) => e.toJson()).toList(),
      "max_tokens": maxTokens,
      "stream": true,
      "stop": "[DONE]",
    };

    var client = http.Client();
    var request = http.Request("POST", uri)
      ..headers.addAll({
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      })
      ..body = json.encode(requestOptions);

    try {
      var streamedResponse = await client.send(request);
      String buffer = "";
      String partialData = "";

      await for (var data in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += data;
        var startIndex = 0;
        var endIndex;

        while ((endIndex = buffer.indexOf("data:", startIndex)) != -1) {
          partialData = buffer.substring(startIndex, endIndex).trim();
          if (partialData.isNotEmpty) {
            final json = extractJsonFromSSEMessage(partialData);
            final content = extractContentFromJson(json);
            onData?.call(content); // Callback with each piece of data
            yield content; // Yield the content
          }
          startIndex = endIndex + 5;
        }
        buffer = buffer.substring(startIndex); // Keep the remaining part for the next iteration
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      client.close();
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Map<String, dynamic> extractJsonFromSSEMessage(String sseMessage) {
  final data = sseMessage.startsWith("data: ") ? sseMessage.substring(5) : sseMessage;
  final converted = (jsonDecode(data) as Map).map((key, value) => MapEntry(key.toString(), value));
  return converted;
}

// Traverse the JSON structure to get to the "content" field.
String extractContentFromJson(Map<String, dynamic> jsonData) {
  if (jsonData.containsKey("choices") &&
      jsonData["choices"] is List &&
      jsonData["choices"].isNotEmpty) {
    var choices = jsonData["choices"] as List;
    if (choices[0].containsKey("delta") && choices[0]["delta"].containsKey("content")) {
      return choices[0]["delta"]["content"];
    }
  }
  return "";
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class OpenAiChatMessage {
  final OpenAiChatRole role;
  final String content;
  OpenAiChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, String> toJson() {
    return {
      "role": role.name.toLowerCase(),
      "content": content,
    };
  }

  String toJsonString() {
    return const JsonEncoder().convert(this.toJson());
  }

  static String messagesToComponent(List<OpenAiChatMessage> messages) {
    final commaSeparated = messages.map((e) => e.toJsonString()).join(",");
    final jsonString = '{"value":[$commaSeparated]}';
    return jsonString;
  }
}
