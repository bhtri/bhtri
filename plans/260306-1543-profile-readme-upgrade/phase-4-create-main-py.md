# Phase 4: Create bin/main.py

## Goal
Python version with identical logic to main.dart. Future replacement option.

## Structure

Same 3 functions + main:

### 4.1 fetch_meigen()

```python
def fetch_meigen():
    """Fetch random Japanese quote from Meigen API."""
    try:
        resp = requests.get('https://meigen.doodlenote.net/api/json.php', params={'c': '1'}, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        if data:
            return {'quote': data[0].get('meigen', ''), 'author': data[0].get('auther', '')}
    except Exception as e:
        print(f'Meigen API error: {e}')
    return {}
```

### 4.2 get_meigen_with_fallback()

```python
def get_meigen_with_fallback():
    meigen = fetch_meigen()
    if meigen:
        return meigen

    # Try yesterday's quote from README
    try:
        if os.path.exists('README.md'):
            content = open('README.md', encoding='utf-8').read()
            quote_match = re.search(r'> (.+)\n', content)
            author_match = re.search(r'— \*\*(.+)\*\*', content)
            if quote_match and author_match:
                return {'quote': quote_match.group(1), 'author': author_match.group(1)}
    except Exception:
        pass

    return {'quote': '本日サーバーが混雑しています。明日また会いましょう。', 'author': 'System'}
```

### 4.3 get_random_dhammapada()

```python
def get_random_dhammapada():
    with open('local_quotes/dhammapada.json', encoding='utf-8') as f:
        data = json.load(f)

    all_verses = []
    for ch in data['chapters']:
        for v in ch['verses']:
            all_verses.append({
                'vi': v['vi'], 'ja': v['ja'],
                'number': v['number'],
                'chapter_vi': ch['name_vi'],
            })

    verse = random.choice(all_verses)
    return {
        'vi': verse['vi'], 'ja': verse['ja'],
        'verse': str(verse['number']), 'chapter': verse['chapter_vi'],
    }
```

### 4.4 main()

```python
def main():
    meigen = get_meigen_with_fallback()
    dhammapada = get_random_dhammapada()
    title = datetime.now().strftime('%Y年%m月%d日')

    template = open('Template.md', encoding='utf-8').read()

    readme = (template
        .replace('{%TITLE%}', title)
        .replace('{%MEIGEN_QUOTE%}', meigen['quote'])
        .replace('{%MEIGEN_AUTHOR%}', meigen['author'])
        .replace('{%DHAMMAPADA_VI%}', dhammapada['vi'])
        .replace('{%DHAMMAPADA_JA%}', dhammapada['ja'])
        .replace('{%DHAMMAPADA_CHAPTER%}', dhammapada['chapter'])
        .replace('{%DHAMMAPADA_VERSE%}', dhammapada['verse']))

    with open('README.md', 'w', encoding='utf-8') as f:
        f.write(readme)
    print('Done!')
```

## Imports

```python
import json
import os
import random
import re
from datetime import datetime
import requests
```

## Dependencies (requirements.txt)

```
requests>=2.31.0
```

## Validation

- [x] `python bin/main.py` runs successfully
- [x] Output README.md identical format to Dart version
- [x] Fallback chain works same as Dart
- [x] UTF-8 encoding correct (Vi diacritics + Ja kanji)
