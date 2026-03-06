# Phase 6: Test + Verify

## Goal
Verify everything works locally before pushing.

## 6.1 Dart Checks

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze
dart bin/main.dart
```

- [ ] All commands pass
- [ ] README.md generated with correct content
- [ ] Meigen section populated (or fallback if API down)
- [ ] Dhammapada section populated with random verse (Vi + Ja)
- [ ] Date formatted correctly (yyyy年MM月dd日)

## 6.2 Python Checks

```bash
pip install -r requirements.txt
python bin/main.py
```

- [ ] Script runs without error
- [ ] README.md output matches Dart version format
- [ ] Both quote sections populated

## 6.3 Data Integrity

```bash
# Verify JSON
python -c "import json; d=json.load(open('local_quotes/dhammapada.json','r',encoding='utf-8')); print(f'Chapters: {len(d[\"chapters\"])}, Verses: {sum(len(c[\"verses\"]) for c in d[\"chapters\"])}')"
# Expected: Chapters: 26, Verses: 423
```

- [ ] JSON: 26 chapters, 423 verses
- [ ] XML: same structure, well-formed
- [ ] UTF-8: Vietnamese diacritics + Japanese kanji display correctly

## 6.4 Workflow Validation

- [ ] YAML syntax valid
- [ ] Test via `workflow_dispatch` after push
- [ ] Monitor first automated run (next daily cron)

## 6.5 Final Commit Plan

```
git add local_quotes/ bin/main.dart bin/main.py Template.md pubspec.yaml requirements.txt .github/workflows/quote_generator.yml
git commit -m "Upgrade profile README: meigen API + dhammapada bilingual quotes"
git push
```

Single commit covering all changes. Clean, atomic.
