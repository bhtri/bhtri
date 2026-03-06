import json
import os
import random
import re
from datetime import datetime

import requests


def fetch_meigen():
    """Fetch a random Japanese quote from Meigen API."""
    try:
        resp = requests.get(
            'https://meigen.doodlenote.net/api/json.php',
            params={'c': '1'},
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()
        if data:
            return {'quote': data[0].get('meigen', ''), 'author': data[0].get('auther', '')}
    except Exception as e:
        print(f'Meigen API error: {e}')
    return {}


def get_meigen_with_fallback():
    """3-tier fallback: API -> yesterday's README -> default message."""
    meigen = fetch_meigen()
    if meigen:
        return meigen

    # Try yesterday's quote from existing README
    try:
        if os.path.exists('README.md'):
            with open('README.md', encoding='utf-8') as f:
                content = f.read()
            quote_match = re.search(r'> (.+)\n', content)
            author_match = re.search(r'— \*\*(.+)\*\*', content)
            if quote_match and author_match:
                quote = quote_match.group(1).strip()
                author = author_match.group(1).strip()
                if quote and author:
                    return {'quote': quote, 'author': author}
    except Exception:
        pass

    return {'quote': '本日サーバーが混雑しています。明日また会いましょう。', 'author': 'System'}


def get_random_dhammapada():
    """Pick a random Dhammapada verse from local JSON."""
    with open('local_quotes/dhammapada.json', encoding='utf-8') as f:
        data = json.load(f)

    # Flatten all verses, skip empty vi text
    all_verses = []
    for ch in data['chapters']:
        for v in ch['verses']:
            if v['vi']:
                all_verses.append({
                    'vi': v['vi'], 'ja': v['ja'],
                    'number': v['number'], 'chapter_vi': ch['name_vi'],
                })

    verse = random.choice(all_verses)
    return {
        'vi': verse['vi'], 'ja': verse['ja'],
        'verse': str(verse['number']), 'chapter': verse['chapter_vi'],
    }


def main():
    try:
        meigen = get_meigen_with_fallback()
        dhammapada = get_random_dhammapada()
        title = datetime.now().strftime('%Y年%m月%d日')

        with open('Template.md', encoding='utf-8') as f:
            template = f.read()

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
    except Exception as e:
        print(f'Error: {e}')
        raise


if __name__ == '__main__':
    main()
