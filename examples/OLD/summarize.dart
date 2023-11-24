import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'old.dart';

final uri = Uri.parse("https://api.openai.com/v1/chat/completions");
final apiKey = "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";

void main() {
  HttpServer.bind(InternetAddress.loopbackIPv4, 8081).then((server) {
    print("Server listening on port ${server.port}");
    server.listen((HttpRequest request) async {
      if (request.uri.path == '/process_document' && request.method == 'POST') {
        await handleDocumentProcessing(request);
      } else {
        // handle other paths...
      }
    });
  });
}

// Process each segment to extract key points
Future<String> summarize(
  String content,
  String apiKey,
  Uri uri,
) async {
  var client = http.Client();
  try {
    var request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      })
      ..body = json.encode({
        "model": "gpt-4",
        "temperature": 1.0,
        "messages": [
          {
            "role": "system",
            "content": //
                "You will be provided with data containing of key points around a central theme. "
                    "Your task is to combine the information into a brief summary.",
          },
          {"role": "user", "content": content},
        ],
        "max_tokens": 2000,
      });

    var streamedResponse = await client.send(request);
    var responseBody = await streamedResponse.stream.bytesToString();

    return responseBody;
  } finally {
    client.close();
  }
}

Future<void> handleDocumentProcessing(HttpRequest request) async {
  var response = request.response;
  response.headers.add('Content-Type', 'text/plain');
  response.headers.add('Cache-Control', 'no-cache');

  try {
    if (request.headers.contentType?.mimeType == 'multipart/form-data') {
      // Process the file upload
      final fileData = await processFileUpload(request);

      final data = await dododo(fileData);
      final summary = await summarize(data.toString(), apiKey, uri);
      response.write(summary);
    } else {
      // Handle other content types or me
      response.statusCode = HttpStatus.badRequest;
      response.write('Unsupported request');
    }
  } catch (e) {
    response.statusCode = HttpStatus.internalServerError;
    response.write('An error occurred: ${e.toString()}');
  } finally {
    await response.close();
  }
}

Future<String> processFileUpload(HttpRequest request) async {
  var boundary = request.headers.contentType?.parameters['boundary'];
  var transformer = MimeMultipartTransformer(boundary!);

  var bodyStream = Stream.fromIterable([await request.single]);
  var parts = await transformer.bind(bodyStream).toList();

  for (var part in parts) {
    var contentDisposition = part.headers['content-disposition'];
    if (contentDisposition != null) {
      var filename = RegExp('filename="([^"]+)"').firstMatch(contentDisposition)?.group(1);
      if (filename != null) {
        // Read the file content directly from the part
        var completer = Completer<String>();
        var contents = StringBuffer();
        var listener = part.listen(
          (data) => contents.write(String.fromCharCodes(data)),
          onDone: () => completer.complete(contents.toString()),
          onError: completer.completeError,
        );

        // Wait for the file content to be read
        var temp = await completer.future;
        temp = await readFileContents(filename, temp);
        listener.cancel();
        return temp;
      }
    }
  }

  // If no file was processed, return an empty string or handle accordingly
  return '';
}

Future<String> readFileContents(String filePath, String data) async {
  final extension = filePath.split('.').last.toLowerCase();
  switch (extension) {
    case 'html':
      return _readHtml(data);
    case 'pdf':
      return data;
    case 'docx':
      return _readDocx(data);
    case 'md':
      return "";
    case 'markdown':
      return "";
    case 'txt':
      return data;
    default:
      return "";
  }
}

String _readHtml(String file) {
  var contents = file;
  var bodyStart = contents.toLowerCase().indexOf('<body>');
  var bodyEnd = contents.toLowerCase().indexOf('</body>');
  if (bodyStart != -1 && bodyEnd != -1) {
    return contents.substring(bodyStart + 6, bodyEnd);
  }
  return '';
}

String _readDocx(String data) {
  final archive = ZipDecoder().decodeBytes(data.codeUnits);
  for (final file in archive) {
    if (file.name == 'word/document.xml') {
      final docXml = XmlDocument.parse(String.fromCharCodes(file.content));
      final textElements = docXml.findAllElements('w:t');
      return textElements.map((node) => node.value).join();
    }
  }
  return 'DOCX content not found';
}

// void main() {
//   HttpServer.bind(InternetAddress.loopbackIPv4, 8081).then((server) {
//     print("HTTP Server listening on port ${server.port}");
//     server.listen((HttpRequest request) async {
//       if (request.uri.path == '/process_document') {
//         await handleDocumentProcessing(request);
//       } else {
//         // handle other paths...
//       }
//     });
//   });
// }

// Future<void> handleDocumentProcessing(HttpRequest request) async {
//   var response = request.response;
//   response.headers.add('Content-Type', 'text/event-stream');
//   response.headers.add('Cache-Control', 'no-cache');
//   response.bufferOutput = false; // Disable buffering

//   try {
//     final webdata = (await fetchHtmlFromUrl("https://www.news.com.au/checkout/tech"))!;
//     final data = await dododo(webdata);
//     response.write(data.toString());
//     await response.close();
//   } catch (e) {
//     response.statusCode = HttpStatus.internalServerError;
//     await response.close();
//   }
// }

Future<dynamic> dododo(String webdata) async {
  try {
    final article = extractArticle(webdata);
    final segments = segmentDocument(article, 1000, 50);
    List<Map<String, String>> points = [];
    for (var segment in segments) {
      try {
        final info = await processSegment(segment, apiKey, uri);
        print(info);
        points.add(info);
      } catch (e) {
        print("error: $e");
      }
    }
    return points;
  } catch (e) {
    return null;
  }
}

List<String> segmentDocument(String document, int bufferLength, int overlap) {
  final words = document.split(" ");

  List<String> segments = [];
  List<String> buffer = [];
  int startIndex = 0;

  for (int i = 0; i < words.length; i++) {
    buffer.add(words[i]);

    // Check if the buffer reached the specified buffer length
    if (buffer.length == bufferLength) {
      segments.add(buffer.join(" "));

      // Ensure overlap is not greater than buffer length
      int actualOverlap = overlap < bufferLength ? overlap : bufferLength - 1;

      // Start the next segment with the overlap of the current segment
      startIndex = i - actualOverlap + 1;
      buffer = words.sublist(startIndex, i + 1);
    }
  }

  // Add any remaining words as the last segment
  if (buffer.isNotEmpty) {
    segments.add(buffer.join(" "));
  }

  return segments;
}

// Process each segment to extract key points
Future<Map<String, String>> processSegment(
  String content,
  String apiKey,
  Uri uri,
) async {
  var client = http.Client();
  try {
    var request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      })
      ..body = json.encode({
        "model": "gpt-3.5-turbo",
        "temperature": 0.5,
        "messages": [
          {
            "role": "system",
            "content": //
                "You will be provided with raw, noisy or corrupt data scraped from a file by an incompetent AI. "
                    "Your task is to determine the central theme of the data, as well as all key-points of information that are relevant to the central theme, then output a JSON object. "
                    "The desired output should look like: "
                    '{"central_theme": "Insert the central theme here", "key_points": ["Key point 1", "Key point 2", "etc."]}. '
          },
          {"role": "user", "content": content},
        ],
        "max_tokens": 2000,
      });

    var streamedResponse = await client.send(request);
    var responseBody = await streamedResponse.stream.bytesToString();
    var responseJson = json.decode(responseBody);

    // Extracting key points or summaries from the response
    // This depends on how your API returns the data
    final parsed = parseResponse(responseJson);

    return parsed;
  } finally {
    client.close();
  }
}

Map<String, String> parseResponse(dynamic responseJson) {
  try {
    final content = responseJson['choices'][0]['message']['content'].toString();
    final decodedContent = json.decode(content) as Map;
    final mappedContent =
        decodedContent.map((key, value) => MapEntry(key.toString(), value.toString()));
    return mappedContent;
  } catch (e) {
    return {};
  }
}
