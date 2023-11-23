enum OpenAiChatRole {
  ASSISTANT,
  USER,
  SYSTEM,
}

OpenAiChatRole? nameToOpenAiChatRole(String? name) {
  if (name != null) {
    for (final a in OpenAiChatRole.values) {
      if (name.trim().toLowerCase() == a.name.toLowerCase()) {
        return a;
      }
    }
  }
  return null;
}
