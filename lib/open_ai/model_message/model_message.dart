//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ AI
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:xyz_gen/xyz_gen.dart';

part 'model_message.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@GenerateModel(
  className: "ModelMessage",
  docPathPattern: null,
  parameters: {
    "role": "String?",
    "content": "String?",
    "timestamp": "int?",
  },
)
abstract class _ModelMessage extends Model {
  _ModelMessage._();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

List<ModelMessage> sortMessageHistory(List<ModelMessage> messages) {
  final sortedMessages = (List.of(messages)..sort((a, b) => a.timestamp!.compareTo(b.timestamp!)));
  return sortedMessages;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

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
