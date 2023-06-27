import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<Map<String, dynamic>> getRandomQuotes() async {
  try {
    // https://github.com/lukePeavey/quotable
    Map<String, dynamic> map = {};
    const String domain = 'api.quotable.io';
    const String path = '/quotes/random';
    final Map<String, dynamic> queryParameters = {
      'limit': '1',
    };

    final Uri uri = Uri.https(domain, path, queryParameters);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isNotEmpty) {
        map.addAll(jsonData[0]);
      }
    } else {
      return Future.error(Exception('Can not get random quotes'));
    }

    return map;
  } catch (e, s) {
    print('Exception details:\n $e');
    print('Stack trace:\n $s');
    return {};
  }
}

void main() async {
  try {
    Map<String, dynamic> map = await getRandomQuotes();
    final DateFormat outputFormat = DateFormat('yyyy年MM月dd日');
    final String quote = map['content'] ?? '';
    final String author = map['author'] ?? '';
    final String title = outputFormat.format(DateTime.now());
    String strReadme = '';

    // https://api.dart.dev/stable/3.0.5/dart-io/File-class.html
    final File file_template = File('Template.md');
    Stream<String> lines = file_template
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());
    try {
      await for (String line in lines) {
        strReadme += '$line\n';
      }
    } catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      return;
    }

    strReadme = strReadme.replaceAll(RegExp(r'{%QUOTE%}'), quote);
    strReadme = strReadme.replaceAll(RegExp(r'{%AUTHOR%}'), author);
    strReadme = strReadme.replaceAll(RegExp(r'{%TITLE%}'), title);

    final File file_readme = File('README.md');
    file_readme.writeAsString(strReadme, mode: FileMode.write, encoding: utf8);

    print('Done!!!');
  } catch (e, s) {
    print('Exception details:\n $e');
    print('Stack trace:\n $s');
  }
}

// https://qiita.com/s-yoshiki/items/436bbe1f7160b610b05c
// https://simpleicons.org/
