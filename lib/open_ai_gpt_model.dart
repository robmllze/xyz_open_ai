//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// © 2023 Robert Mollentze
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

final class OpenAiGptModels {
  static const gpt4 = OpenAiGptModel(
    name: "gpt-4",
    description:
        "More capable than any GPT-3.5 model, able to do more complex tasks, and optimized for chat. Will be updated with our latest model iteration 2 weeks after it is released.",
    maxTokens: 8192,
    trainingData: "Up to Sep 2021",
  );

  static const gpt4_0613 = OpenAiGptModel(
    name: "gpt-4-0613",
    description:
        "Snapshot of gpt-4 from June 13th 2023 with function calling data. Unlike gpt-4, this model will not receive updates, and will be deprecated 3 months after a new version is released.",
    maxTokens: 8192,
    trainingData: "Up to Sep 2021",
  );

  static const gpt4_32k = OpenAiGptModel(
    name: "gpt-4-32k",
    description:
        "Same capabilities as the base gpt-4 model but with 4x the context length. Will be updated with our latest model iteration.",
    maxTokens: 32768,
    trainingData: "Up to Sep 2021",
  );

  static const gpt4_32k_0613 = OpenAiGptModel(
    name: "gpt-4-32k-0613",
    description:
        "Snapshot of gpt-4-32k from June 13th 2023. Unlike gpt-4-32k, this model will not receive updates, and will be deprecated 3 months after a new version is released.",
    maxTokens: 32768,
    trainingData: "Up to Sep 2021",
  );

  static const gpt3_5_turbo = OpenAiGptModel(
    name: "gpt-3.5-turbo",
    description:
        "Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of text-davinci-003. Will be updated with our latest model iteration 2 weeks after it is released.",
    maxTokens: 4096,
    trainingData: "Up to Sep 2021",
  );

  static const gpt3_5_turbo_1106 = OpenAiGptModel(
    name: "gpt-3.5-turbo-1106",
    description:
        "The latest GPT-3.5 Turbo model with improved instruction following, JSON mode, reproducible outputs, parallel function calling, and more. Returns a maximum of 4,096 output tokens.",
    maxTokens: 4096,
    trainingData: "Up to Sep 2021",
  );

  static const gpt3_5_turbo_16k = OpenAiGptModel(
    name: "gpt-3.5-turbo-16k",
    description:
        "Same capabilities as the standard gpt-3.5-turbo model but with 4 times the context.",
    maxTokens: 16384,
    trainingData: "Up to Sep 2021",
  );

  static const textDavinci003 = OpenAiGptModel(
    name: "text-davinci-003",
    description:
        "Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports some additional features such as inserting text.",
    maxTokens: 4097,
    trainingData: "Up to Jun 2021",
  );

  static const textDavinci002 = OpenAiGptModel(
    name: "text-davinci-002",
    description:
        "Similar capabilities to text-davinci-003 but trained with supervised fine-tuning instead of reinforcement learning",
    maxTokens: 4097,
    trainingData: "Up to Jun 2021",
  );

  static const codeDavinci002 = OpenAiGptModel(
    name: "code-davinci-002",
    description: "Optimized for code-completion tasks",
    maxTokens: 8001,
    trainingData: "Up to Sep 2021",
  );

  static const textCurie001 = OpenAiGptModel(
    name: "text-curie-001",
    description: "Very capable, faster and lower cost than Davinci.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const textBabbage001 = OpenAiGptModel(
    name: "text-babbage-001",
    description: "Capable of straightforward tasks, very fast, and lower cost.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const textAda001 = OpenAiGptModel(
    name: "text-ada-001",
    description:
        "Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const davinci = OpenAiGptModel(
    name: "davinci",
    description:
        "Most capable GPT-3 model. Can do any task the other models can do, often with higher quality.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const curie = OpenAiGptModel(
    name: "curie",
    description: "Very capable, but faster and lower cost than Davinci.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const babbage = OpenAiGptModel(
    name: "babbage",
    description: "Capable of straightforward tasks, very fast, and lower cost.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );

  static const OpenAiGptModel ada = OpenAiGptModel(
    name: "ada",
    description:
        "Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.",
    maxTokens: 2049,
    trainingData: "Up to Oct 2019",
  );
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class OpenAiGptModel {
  final String name;
  final String description;
  final int maxTokens;
  final String trainingData;

  const OpenAiGptModel({
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.trainingData,
  });
}
