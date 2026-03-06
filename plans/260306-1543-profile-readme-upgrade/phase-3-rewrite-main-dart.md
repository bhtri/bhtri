# Phase 3: Rewrite bin/main.dart

## Goal
Replace dead quotable.io with Meigen API + Dhammapada local JSON. Add fallback logic. Fix code quality.

## Changes Summary

| What | Remove | Add |
|------|--------|-----|
| Quote API | quotable.io | meigen.doodlenote.net |
| SSL bypass | `badCertificateCallback` | Standard HTTPS (no bypass) |
| Dhammapada | — | Random from local JSON |
| Env dump | `envVars.forEach` print all | Remove entirely |
| Naming | `file_template`, `file_readme` | `fileTemplate`, `fileReadme` |
| Placeholders | `{%QUOTE%}`, `{%AUTHOR%}` | 7 new placeholders |

## 3.1 Function: fetchMeigen()

```dart
Future<Map<String, String>> fetchMeigen() async {
  try {
    final uri = Uri.https('meigen.doodlenote.net', '/api/json.php', {'c': '1'});
    final response = await get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'quote': data[0]['meigen'] ?? '',
          'author': data[0]['auther'] ?? '',  // API typo: "auther"
        };
      }
    }
    return {};
  } catch (e) {
    print('Meigen API error: $e');
    return {};
  }
}
```

**Key**: No SSL bypass needed. Standard `package:http` `get()`.

## 3.2 Function: getRandomDhammapada()

```dart
Map<String, String> getRandomDhammapada() {
  final file = File('local_quotes/dhammapada.json');
  final data = jsonDecode(file.readAsStringSync());
  final chapters = data['chapters'] as List;

  // Flatten all verses with chapter info
  final allVerses = <Map<String, dynamic>>[];
  for (final ch in chapters) {
    for (final v in ch['verses']) {
      allVerses.add({
        'vi': v['vi'],
        'ja': v['ja'],
        'number': v['number'],
        'chapter_vi': ch['name_vi'],
        'chapter_ja': ch['name_ja'],
      });
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
```

## 3.3 Fallback Logic for Meigen

```dart
Future<Map<String, String>> getMeigenWithFallback() async {
  // 1. Try API
  var meigen = await fetchMeigen();
  if (meigen.isNotEmpty) return meigen;

  // 2. Try yesterday's quote from current README
  try {
    final readme = File('README.md');
    if (readme.existsSync()) {
      final content = readme.readAsStringSync();
      // Parse meigen from existing README using regex
      final quoteMatch = RegExp(r'> (.+)\n').firstMatch(content);
      final authorMatch = RegExp(r'— \*\*(.+)\*\*').firstMatch(content);
      if (quoteMatch != null && authorMatch != null) {
        return {
          'quote': quoteMatch.group(1)!,
          'author': authorMatch.group(1)!,
        };
      }
    }
  } catch (_) {}

  // 3. Default fallback
  return {
    'quote': '本日サーバーが混雑しています。明日また会いましょう。',
    'author': 'System',
  };
}
```

## 3.4 Updated main()

```dart
void main() async {
  try {
    // Fetch data
    final meigen = await getMeigenWithFallback();
    final dhammapada = getRandomDhammapada();
    final title = DateFormat('yyyy年MM月dd日').format(DateTime.now());

    // Read template
    final template = File('Template.md').readAsStringSync();

    // Replace placeholders
    var readme = template
        .replaceAll('{%TITLE%}', title)
        .replaceAll('{%MEIGEN_QUOTE%}', meigen['quote']!)
        .replaceAll('{%MEIGEN_AUTHOR%}', meigen['author']!)
        .replaceAll('{%DHAMMAPADA_VI%}', dhammapada['vi']!)
        .replaceAll('{%DHAMMAPADA_JA%}', dhammapada['ja']!)
        .replaceAll('{%DHAMMAPADA_CHAPTER%}', dhammapada['chapter']!)
        .replaceAll('{%DHAMMAPADA_VERSE%}', dhammapada['verse']!);

    // Write output
    File('README.md').writeAsStringSync(readme);
    print('Done!');
  } catch (e, s) {
    print('Error: $e\n$s');
  }
}
```

## Removed

- `badCertificateCallback` SSL bypass
- `IOClient` import (use standard `get()` from `package:http`)
- `Platform.environment` env vars dump (prints secrets!)
- `LineSplitter` stream reading (replaced with `readAsStringSync`)
- Old quotable.io endpoint

## Validation

- [x] `dart analyze` passes with no issues
- [x] `dart format --set-exit-if-changed .` passes
- [x] No `badCertificateCallback` in code
- [x] No `Platform.environment` dump
- [x] All 7 placeholders replaced correctly
- [x] Fallback chain works: API fail → README parse → default message
