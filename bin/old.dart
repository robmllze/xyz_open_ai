import "dart:io";

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html;

List<String> splitIntoChunks(String str, [int chunkSize = 4000]) {
  var length = str.length;
  var chunks = <String>[];

  for (var i = 0; i < length; i += chunkSize) {
    var end = (i + chunkSize < length) ? i + chunkSize : length;
    chunks.add(str.substring(i, end));
  }

  return chunks;
}

Future<void> masdsdin() async {
  // final articles = await fetchNewsArticles("business");
  // final urls = articles.map((e) => e["url"].toString());
  // final descriptions = articles.map((e) => e["description"].toString());

  //final urls = (await getNewsUrlsFromRss("http://feeds.bbci.co.uk/news/rss.xml")).toList();
  //final urls = (await getNewsUrlsFromRss("http://rss.cnn.com/rss/edition.rss")).toList();
  //final urls = (await getNewsUrlsFromRss("https://www.aljazeera.com/xml/rss/all.xml")).toList();
  // final abcNewsUrls =
  //     (await getNewsUrlsFromRss("https://www.abc.net.au/news/feed/45910/rss.xml")).toList();

  // final sbsNewsUrls = (await getNewsUrlsFromRss("https://www.sbs.com.au/news/feed")).toList();

  // final smhNewsUrls = (await getNewsUrlsFromRss("https://www.smh.com.au/rss-feed.xml")).toList();

  // final theAgeNewsUrls =
  //     (await getNewsUrlsFromRss("https://www.theage.com.au/rss-feed.xml")).toList();

  // final newsComAuNationalUrls =
  //     (await getNewsUrlsFromRss("https://www.news.com.au/content-feeds/latest-news-national"))
  //         .toList();

  final urls = ["https://www.mirror.co.uk/news/weird-news/woman-worlds-biggest-lips-now-29292574"];

  for (final url in urls) {
    final webpage = await fetchHtmlFromUrl(url);
    if (webpage == null) continue;
    final article = extractArticle(webpage);

    final articleChunks = splitIntoChunks(article, 3000);

    List<String> responses = [];

    for (final chunk in articleChunks) {
      final response = await chatWithGPT(
        "Task: Extract key information from the provided text chunk, which is part of a larger article scraped from an HTML website. "
        "Create a numbered list of key points, including names, places, statements, and relevant details. "
        "Ignore: information not related to news, author/reporter names, platform details, website code, metadata, links, ads, and other non-content related elements. "
        "You may respond with '- no relevant information in this chunk' if appropriate."
        "The chunk:\n"
        "$chunk",
        3000,
        0.6,
      );
      responses.add(response);
    }

    if (responses.length == 0) {
      print("No key points found");
      continue;
    }

    print(responses);

    var prompt =
        "Task: Create a concise, engaging news article using the key points below and do not cite the source of these key points. The article is for a physical newspaper, so avoid any mention of website elements, cookie policies, etc. Write as if this is original content for print. The key points are:\n${responses.join("\n")}";
    prompt = prompt.substring(0, prompt.length > 3000 ? 3000 : prompt.length);
    final generatedArticle = await chatWithGPT(
      prompt,
      3000,
      0.6,
    );

    print(generatedArticle);

    // final prompt1 = [
    //   'Task: Create a question inspired by the given article, seeking my opinion with 4 multiple-choice options.',
    //   '',
    //   'Adhere to the following checklist:',
    //   "- The question should seek my opinion and be framed without referencing the article or specific details within the article",
    //   '- Avoid any mention or allusion to the existence of an article, studies, events, or data in both the question and options',
    //   '- Ensure that the question is related to the central theme of the article without directly referencing the article',
    //   '- Phrase the question and options in layman’s terms to ensure accessibility and comprehension',
    //   '- If the article does not concern Australia, avoid making the question specific to a particular country to maintain a global perspective',
    //   '- If the article mentions Australia include the state and area it in the question without indicating the source',
    //   '- Your response should be in the following JSON format:',
    //   '',
    //   '{',
    //   ' "tags": ["add", "search", "tags", "describing", "the", "topic", "here"],',
    //   ' "question": "put question here",',
    //   ' "answers": {',
    //   ' "A": "put conservative answer here",',
    //   ' "B": "put liberal answer here",',
    //   ' "C": "put moderate answer here",',
    //   ' "D": "put answer here that challenges the accuracy of the given information while being a valid answer to the question"',
    //   ' }',
    //   '}',
    //   '',
    //   'Here is the given article:"\n',
    //   generatedArticle,
    //   '',
    // ].join("\n");

    final prompt1 = [
      'Task: Create a question based on the provided article that seeks the reader’s opinions or thoughts on the implications, reactions, or subjective aspects related to the information, not on the factual content itself. Accompany the question with four multiple-choice options.',
      '',
      'Rules:',
      '- The question must not contain the word "article" or "study" or any words that allude to the existence of an article, studies, events, or data.'
          '- The question should explore opinions on subjective or debatable aspects, avoiding queries on established or proven facts.',
      '- Phrase the question and options in layman’s terms for broad accessibility.',
      '- If the article mentions Australia, include the state and area in the question without indicating the source. If not, avoid making the question country-specific.',
      '- The question should relate to the broader implications, societal reactions, or ethical considerations tied to the information, not the information itself.',
      '',
      'Provide your response in this JSON format:',
      '{',
      ' "tags": [Insert relevant tags, like state, suburb, topic, people involved, etc., as strings separated by commas],',
      ' "question": "Insert question here",',
      ' "answers": {',
      ' "A": "Insert a conservative perspective answer here",',
      ' "B": "Insert a liberal perspective answer here",',
      ' "C": "Insert a moderate perspective answer here",',
      ' "D": "Insert an answer here that challenges the validity or accuracy of the information while being a valid perspective"',
      ' }',
      '}',
      '',
      'Given article:',
      generatedArticle,
    ].join("\n");

    final question = await chatWithGPT(
      prompt1,
      3000,
      0.8,
    );

    print(question);

    final prompt2 = [
      'Tasks:',
      '- Ensure the given question is self-explanatory, and avoids references to specific articles, external information, studies, or events, and directly seeks the readers opinion',
      '- Modify the question to be clear and engaging for readers aged 12-24 without mentioning their age',
      '- If the given question is already good, respond with the original question',
      '- Provide your response in this JSON format:',
      '{',
      ' "tags": [Insert relevant tags, like state, suburb, topic, people involved, etc., as strings separated by commas],',
      ' "question": "Insert question here",',
      ' "answers": {',
      ' "A": "Insert a conservative perspective answer here",',
      ' "B": "Insert a liberal perspective answer here",',
      ' "C": "Insert a moderate perspective answer here",',
      ' "D": "Insert an answer here that challenges the validity or accuracy of the information while being a valid perspective"',
      ' }',
      '}',
      '',
      'Given question:',
      question,
    ].join("\n");

    final fixedQuestion = await chatWithGPT(
      prompt2,
      3000,
      0.8,
    );

    print("\n\n");

    print(fixedQuestion);

    // for (var i = 0; i < urls.length && i < 2; i++) {
    //   final url = urls[i];
    //   //final description = descriptions.elementAt(i);
    //   final quiz = await createOpinionQuizFromUrl(
    //       "https://www.skynews.com.au/australia-news/police-deploy-800-officers-in-preparation-for-crowd-of-10000-expected-to-turn-up-at-sydneys-third-sydney-propalestine-rally/news-story/76d61a2396dec77317b1d577a12a1b8a");
    //   if (quiz == null) {
    //     print("Failed to create quiz from $url");
    //     continue;
    //   }
    //   print(
    //     "Source: $url\n"
    //     "$quiz\n\n\n",
    //   );
    // }
  }
}

String removeHtmlTags(String htmlString) {
  var output = StringBuffer();
  var isInsideTag = false;

  for (var char in htmlString.split('')) {
    if (char == '<') {
      isInsideTag = true;
      continue;
    }

    if (char == '>') {
      isInsideTag = false;
      continue;
    }

    if (!isInsideTag) {
      output.write(char);
    }
  }

  return output.toString();
}

Future<List<String>> getNewsUrlsFromRss(String rssFeedUrl) async {
  var url = Uri.parse(rssFeedUrl);
  var response = await http.get(url);
  var articleUrls = <String>[];

  if (response.statusCode == 200) {
    var document = XmlDocument.parse(utf8.decode(response.bodyBytes));
    var items = document.findAllElements('item');
    articleUrls = items.map((item) => item.findElements('link').first.text).toList();
  } else {
    print("Failed to load RSS feed");
  }

  return articleUrls;
}

Future<List<Map<String, dynamic>>> fetchNewsArticles(String category) async {
  final now = DateTime.now();
  final from = now.subtract(Duration(days: 10)).toUtc().toIso8601String().split("T")[0];
  final today = now.subtract(Duration(days: 3)).toUtc().toIso8601String().split("T")[0];
  final domains = [
    "abc.net.au",
    "adelaidenow.com.au",
    "canberratimes.com.au",
    "couriermail.com.au",
    "dailytelegraph.com.au",
    "geelongadvertiser.com.au",
    "goldcoastbulletin.com.au",
    "heraldsun.com.au",
    "illawarramercury.com.au",
    "newcastleherald.com.au",
    "news.com.au",
    "ntnews.com.au",
    "perthnow.com.au",
    "skynews.com.au",
    "smh.com.au",
    "theage.com.au",
    "theaustralian.com.au",
    "themercury.com.au",
    "thewest.com.au",
    "townsvillebulletin.com.au",
  ].join(",");

  final apiKey = "e4f509f95b364e529b953ef00654c1f7";
  var url = Uri.parse(
      "https://newsapi.org/v2/everything?q=$category&from=$from&to=$today&sortBy=relevancy&domains=$domains&apiKey=$apiKey");

  final response = await http.get(url);
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List articles = data["articles"];
    return articles.map((article) {
      return {"url": article["url"], "description": article["description"]};
    }).toList();
  } else {
    throw Exception("Failed to load news articles");
  }
}

Future<Quiz?> createOpinionQuizFromUrl(String url, [String description = ""]) async {
  Quiz? result;

  // Reads the file content as a string
  final content = await fetchHtmlFromUrl(url);

  if (content == null) return null;

  for (var attempts = 0; attempts < 3; attempts++) {
    try {
      const bufferSize = 3000;
      final prompt1 = [
        'Use the given article to generate 1 question asking for my opinion and 4 multiple-choice possibilities.',
        'The article is scraped from the web and may be incomplete or inaccurate.',
        '',
        'You cannot break the following rules when generating your response:',
        '- Your must generate opinion questions, not fact questions.',
        '- Start your question with words that make it clear that you\'re asking for my opinion and not facts.',
        '- Your question must relate to the central theme of the article.',
        '- You must assume I have no prior knowledge of the article.',
        '- Do not use words like "article" "text" "news" "this", "article", etc.',
        '- You must not reference the article in your response.',
        '- Your question must be framed in layman\'s terms, not in the language of the article.',
        '- You must generate 4 multiple-choice answers. Separate each answer with a new line.',
        '- Your question must always mention the country, state or area if relevant.',
        '',
        'Your response should be in the following JSON format:',
        '',
        '{',
        ' "tags": ["add", "search", "tags", "describing", "the", "topic", "here"],',
        ' "question": "put question here",',
        ' "answers": {',
        ' "A": "put conservative answer here",',
        ' "B": "put liberal answer here",',
        ' "C": "put moderate answer here",',
        ' "D": "put answer here that challenges the accuracy of the given information while being a valid answer to the question"',
        ' }',
        '}',
        '',
        'Here is the given article:"\n',
        description,
        '',
      ].join("\n");

      final article = extractArticle(content);

      final finalPrompt = "$prompt1$article";

      var response = await chatWithGPT(
        finalPrompt,
        bufferSize,
        0.7,
      );

      result = Quiz.fromJson(response);
      break;
    } catch (_) {}
  }
  return result;
}

String removeNonAlphabeticChars(String input) {
  return input.replaceAll(RegExp("[^a-zA-Z .]"), "");
}

Future<String?> fetchHtmlFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    }
  } catch (_) {}

  return null;
}

// Replace with your own OpenAI API key
//const apiKey = "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";

Future<String> chatWithGPT(String prompt, int maxTokens, double temperature) async {
  return "";
  // // API endpoint for the GPT-3 model
  // var url = Uri.parse("https://api.openai.com/v1/engines/gpt-3.5-turbo-instruct/completions");

  // var response = await http.post(
  //   url,
  //   headers: {
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     HttpHeaders.authorizationHeader: "Bearer $apiKey",
  //   },
  //   body: json.encode({
  //     "prompt": prompt,
  //     "max_tokens": maxTokens,
  //     "temperature": temperature,
  //   }),
  // );

  // if (response.statusCode == 200) {
  //   var data = json.decode(response.body);
  //   return data["choices"][0]["text"].trim();
  // } else {
  //   throw Exception("Failed to get response from OpenAI API");
  // }
}

class Quiz {
  Set<String> tags;
  String question;
  Map<String, String> answers;

  Quiz(this.tags, this.question, this.answers);

  factory Quiz.fromJson(String encoded) {
    final decoded = jsonDecode(encoded);

    final tags = (decoded["tags"] as List).map((e) => e.toString().toLowerCase()).toSet();
    final question = decoded["question"].toString();
    final answers = (decoded["answers"] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
    return Quiz(tags, question, answers);
  }

  Map<String, dynamic> toJson() {
    return {
      "tags": tags,
      "question": question,
      "answers": answers,
    };
  }

  @override
  String toString() {
    return ["$question\n", ...answers.values.map((e) => "- $e"), "\nTags: ${tags.join(", ")}"]
        .join("\n");
  }
}

//
//
//

String getHtmlBody(String htmlString) {
  var document = html.parse(htmlString);
  return document.body!.text;
}

String extractArticle(String content) {
  final body = getHtmlBody(content);
  final bodyLines = body.split("\n");

  // A list to store chunks of content and their analysis
  var chunks = <ChunkInfo>[];

  // Splits the content into chunks and analyze each chunk
  for (final line in bodyLines) {
    final chunkInfo = ChunkInfo(chunk: line);
    chunks.add(chunkInfo);
  }

  return findAndJoinValidChunks(chunks);
}

//
//
//

// Finds the chunks that pass the test and joins them together
String findAndJoinValidChunks(List<ChunkInfo> chunks) {
  final chain = <String>[];

  // Iterates over the chunks and builds chains of passing chunks
  for (var chunk in chunks) {
    if (chunk.valid) {
      chain.add(chunk.chunk);
    }
  }

  // Joins the chunks in the longest chain and returns the result
  return chain.join("...");
}

//
//
//

// Stores information about a chunk of content
class ChunkInfo {
  final String chunk;

  ChunkInfo({required this.chunk});

  bool get valid => isValidChunk(chunk);
}

//
//
//

// Reads the content of a file and returns it as a string
Future<String> readFileAsString(String filePath) async {
  try {
    final file = File(filePath);
    final contents = await file.readAsString();
    return contents;
  } on FileSystemException catch (e) {
    print("Error reading file: $e");
    return "";
  }
}

//
//
//

String removeHeadSection(String htmlContent) {
  var startHeadIndex = htmlContent.indexOf("<head>");
  var endHeadIndex = htmlContent.indexOf("</head>");

  if (startHeadIndex == -1 || endHeadIndex == -1) {
    // Trying with uppercase tags if not found with lowercase tags
    startHeadIndex = htmlContent.indexOf("<HEAD>");
    endHeadIndex = htmlContent.indexOf("</HEAD>");
  }

  if (startHeadIndex != -1 && endHeadIndex != -1) {
    var beforeHead = htmlContent.substring(0, startHeadIndex);
    var afterHead =
        htmlContent.substring(endHeadIndex + 7); // 7 is the length of "</head>" or "</HEAD>"
    return beforeHead + afterHead;
  } else {
    // Using case-insensitive regular expression to remove <head> section if not found with exact case tags
    var headRegExp = RegExp(r"<head>.*?</head>", caseSensitive: false, multiLine: true);
    return htmlContent.replaceAll(headRegExp, "");
  }
}

//
//
//

final ua = "a".codeUnitAt(0);
final uz = "z".codeUnitAt(0);
final uA = "A".codeUnitAt(0);
final uZ = "Z".codeUnitAt(0);
final u0 = "0".codeUnitAt(0);
final u9 = "9".codeUnitAt(0);
final uSpace = " ".codeUnitAt(0);

bool isAlphabetical(String char) {
  final codeUnit = char.codeUnitAt(0);
  return (codeUnit >= uA && codeUnit <= uZ) || (codeUnit >= ua && codeUnit <= uz);
}

bool isSpace(String char) {
  final codeUnit = char.codeUnitAt(0);
  return codeUnit == uSpace;
}

bool isNumeric(String char) {
  final codeUnit = char.codeUnitAt(0);
  return codeUnit >= u0 && codeUnit <= u9;
}

double getAlphabeticalRatio(String input) {
  return charRatio(input, (e) => isAlphabetical(e) || isSpace(e) || isNumeric(e));
}

double getSpaceRatio(String input) {
  return charRatio(input, (e) => isSpace(e));
}

double getNumericRatio(String input) {
  return charRatio(input, (e) => isNumeric(e));
}

int countSentences(String text) {
  int count = 0;

  for (int i = 0; i < text.length; i++) {
    if (text[i] == "." || text[i] == "!" || text[i] == "?") {
      // Ensure that we"re not counting sentence-ending punctuation
      // that are immediately followed by another sentence-ending punctuation
      if (i == text.length - 1 ||
          (text[i + 1] != "." && text[i + 1] != "!" && text[i + 1] != "?")) {
        count++;
      }
    }
  }

  return count;
}

bool isValidChunk(String chunk) {
  // More than 85% must be alphabetical characters.
  final a = getAlphabeticalRatio(chunk);
  if (a < 0.85) return false;

  // Less than 25% of the paragraph can be spaces.
  final b = getSpaceRatio(chunk);
  if (b > 0.25) return false;

  // Less than 20% of the paragraph can be numbers.
  final c = getNumericRatio(chunk);
  if (c > 0.2) return false;

  // final chunkLength = chunk.length;

  // if (chunkLength > 500) {
  //   // Must have at least 1 sentence per chunk and 1 sentence per 500 characters.
  //   final sentenceCount = countSentences(chunk);
  //   final minSentences = (chunkLength / 500).truncate();
  //   if (sentenceCount == 0 || sentenceCount < minSentences) {
  //     return false;
  //   }
  // }
  return true;
}

//
//
//

double charRatio(String input, bool Function(String char) test) {
  if (input.isNotEmpty) {
    var count = 0;

    for (var i = 0; i < input.length; i++) {
      if (test(input[i])) {
        count++;
      }
    }
    final ratio = count / input.length;
    return ratio;
  }
  return 0;
}

//
//
//

String trimNonAlphabeticalCharacters(String input) {
  int start = 0;
  int end = input.length - 1;

  // Finding the index of the first alphabetical character
  while (start < input.length && !isAlphabetical(input[start])) {
    start++;
  }

  // Finding the index of the last alphabetical character
  while (end >= 0 && !isAlphabetical(input[end])) {
    end--;
  }

  if (start <= end) {
    return input.substring(start, end + 1);
  }

  return ""; // Return an empty string if no alphabetical characters are found
}
