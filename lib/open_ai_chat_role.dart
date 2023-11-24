enum ChatRole {
  ASSISTANT,
  USER,
  SYSTEM,
}

ChatRole? nameToOpenAiChatRole(String? name) {
  if (name != null) {
    for (final a in ChatRole.values) {
      if (name.trim().toLowerCase() == a.name.toLowerCase()) {
        return a;
      }
    }
  }
  return null;
}
