import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Fetch a random Japanese quote from Meigen API
Future<Map<String, String>> fetchMeigen() async {
  try {
    final uri = Uri.https('meigen.doodlenote.net', '/api/json.php', {'c': '1'});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'quote': data[0]['meigen'] ?? '',
          'author': data[0]['auther'] ?? '', // API typo: "auther"
        };
      }
    }
    return {};
  } catch (e) {
    print('Meigen API error: $e');
    return {};
  }
}

/// Get meigen with 3-tier fallback: API → yesterday's README → default message
Future<Map<String, String>> getMeigenWithFallback() async {
  var meigen = await fetchMeigen();
  if (meigen.isNotEmpty) {
    return meigen;
  }

  try {
    final readme = File('README.md');
    if (readme.existsSync()) {
      final content = readme.readAsStringSync();
      final quoteMatch = RegExp(r'> (.+)\n').firstMatch(content);
      final authorMatch = RegExp(r'— \*\*(.+)\*\*').firstMatch(content);

      if (quoteMatch != null && authorMatch != null) {
        final quote = quoteMatch.group(1)?.trim() ?? '';
        final author = authorMatch.group(1)?.trim() ?? '';
        if (quote.isNotEmpty && author.isNotEmpty) {
          return {
            'quote': quote,
            'author': author,
          };
        }
      }
    }
  } catch (_) {
    // ignore
  }

  return {
    'quote': '本日サーバーが混雑しています。明日また会いましょう。',
    'author': 'System',
  };
}

/// Pick a random Dhammapada verse from local JSON
Map<String, String> getRandomDhammapada() {
  final file = File('local_quotes/dhammapada.json');
  final data = jsonDecode(file.readAsStringSync());
  final chapters = data['chapters'] as List;

  // Flatten all verses with chapter info, skip verses with empty vi text
  final allVerses = <Map<String, dynamic>>[];
  for (final ch in chapters) {
    for (final v in ch['verses']) {
      if ((v['vi'] as String).isNotEmpty) {
        allVerses.add({
          'vi': v['vi'],
          'ja': v['ja'],
          'number': v['number'],
          'chapter_vi': ch['name_vi'],
        });
      }
    }
  }

  final random = Random();
  final verse = allVerses[random.nextInt(allVerses.length)];
  return {
    'vi': verse['vi'],
    'ja': verse['ja'],
    'verse': verse['number'].toString(),
    'chapter': verse['chapter_vi'],
  };
}

void main() async {
  try {
    final meigen = await getMeigenWithFallback();
    final dhammapada = getRandomDhammapada();
    final title = DateFormat('yyyy年MM月dd日').format(DateTime.now());

    final template = File('Template.md').readAsStringSync();

    var readme = template
        .replaceAll('{%TITLE%}', title)
        .replaceAll('{%MEIGEN_QUOTE%}', meigen['quote']!)
        .replaceAll('{%MEIGEN_AUTHOR%}', meigen['author']!)
        .replaceAll('{%DHAMMAPADA_VI%}', dhammapada['vi']!)
        .replaceAll('{%DHAMMAPADA_JA%}', dhammapada['ja']!)
        .replaceAll('{%DHAMMAPADA_CHAPTER%}', dhammapada['chapter']!)
        .replaceAll('{%DHAMMAPADA_VERSE%}', dhammapada['verse']!);

    File('README.md').writeAsStringSync(readme);
    print('Done!');
  } catch (e, s) {
    print('Error: $e\n$s');
  }
}
