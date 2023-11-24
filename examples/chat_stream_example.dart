//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ AI
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:io';

import 'package:xyz_open_ai/open_ai_chat.dart';
import 'package:xyz_open_ai/open_ai_chat_role.dart';
import 'package:xyz_open_ai/open_ai_gpt_model.dart';
import 'package:xyz_open_ai/test_data/alcoholic_drinks.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main() async {
  print("Word count: ${TEST_DATA__ALCOHOLIC_DRINKS.split(" ").length}");

  final client = OpenAIClient(
    apiKey: "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",
  );

  final stream = client.getOpenAiChatCompletionStream(
    maxTokens: 3000,
    model: const GPTModel("gpt-4-1106-preview"),
    messages: [
      ChatMessage(
        role: ChatRole.SYSTEM,
        content: "You're a function that takes text and summarizes it.",
      ),
      ChatMessage(
        role: ChatRole.USER,
        content: "Summarize the following: $TEST_DATA__ALCOHOLIC_DRINKS",
      ),
    ],
    onData: (buffer) {
      stdout.write(buffer);
    },
  );
  stream.listen((event) {});
}
