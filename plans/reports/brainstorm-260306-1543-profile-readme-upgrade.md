# Brainstorm: Profile README Upgrade

## Problem Statement

Project `bhtri` (GitHub Profile README auto-updater) has multiple outdated dependencies, a dead quote API (`api.quotable.io` archived), and needs new features: Japanese meigen quotes + Buddhist Dhammapada verses (bilingual Vi+Ja).

## Research Findings

### Dead/Outdated Components

| Component | Current | Status |
|-----------|---------|--------|
| `api.quotable.io` | Used in main.dart | **DEAD** (repo archived) |
| `http` package | `^1.1.0` | Outdated → `^1.6.0` |
| `intl` package | `^0.19.0` | Outdated → `^0.20.0` |
| Dart SDK | `^3.0.5` | Outdated → `^3.4.0` |
| `ghaction-github-pages` | `v3.1.0` | Outdated → `v4.2.0` |
| `profile-summary-cards` | `v0.6.1` | Outdated → `v0.7.0` |
| SSL bypass | `badCertificateCallback` → true | Security risk, unnecessary |

### New Quote Sources

| Source | Type | Details |
|--------|------|---------|
| Meigen API | Remote API | `meigen.doodlenote.net/api/json.php?c=1` — free, no key, Japanese quotes |
| Kinh Phap Cu (Dhammapada) | Local DB | 423 verses, 26 chapters — bilingual Vi+Ja |

### Dhammapada Sources (scrape once, store locally)

- Vietnamese: `loiphatday.org/kinh-phap-cu/` (26 pham, 423 bai ke)
- Japanese: `true-buddhism.com/sutra/dhammapada/` (26 章, 423 偈)
- Both sources match 1:1 in structure (26 chapters, 423 verses)

## Agreed Solution

### 1. Quote System Redesign

**Meigen API** (Japanese famous quotes):
- Endpoint: `meigen.doodlenote.net/api/json.php?c=1` (no `e=1`, direct UTF-8)
- Response: `[{meigen: "...", auther: "..."}]` (note: `auther` is API's typo)
- Fallback chain: API → yesterday's quote from current README → "本日サーバーが混雑しています"

**Dhammapada** (Buddhist verses, bilingual):
- Storage: `local_quotes/dhammapada.json` + `local_quotes/dhammapada.xml` (synced, same order)
- Selection: Random each day
- Code reads from JSON (simpler for both Dart and Python)
- Scrape script: Python (run once, discard script after)

### 2. Template Redesign

Two quote sections in `Template.md`:

```
---
### **{%TITLE%}**

**🌸 名言 (Meigen)**

<blockquote>{%MEIGEN_QUOTE%}</blockquote>
<p align="right">— {%MEIGEN_AUTHOR%}</p>

**📿 Kinh Pháp Cú (Dhammapada)**

<blockquote>
{%DHAMMAPADA_VI%}

<i>{%DHAMMAPADA_JA%}</i>
</blockquote>
<p align="right">— {%DHAMMAPADA_CHAPTER%}, Kệ {%DHAMMAPADA_VERSE%}</p>

---
```

### 3. Dual Implementation

| Aspect | Dart (main.dart) | Python (main.py) |
|--------|-------------------|-------------------|
| HTTP | `package:http` ^1.6.0 | `requests` |
| JSON | `dart:convert` | `json` (built-in) |
| Date format | `package:intl` ^0.20.0 | `datetime` |
| Random | `dart:math` | `random` |
| Fallback | Parse current README.md | Same logic |

### 4. Local Quotes Data Structure

```json
{
  "metadata": {
    "title_vi": "Kinh Pháp Cú",
    "title_ja": "法句経（ダンマパダ）",
    "total_verses": 423,
    "total_chapters": 26,
    "source_vi": "loiphatday.org",
    "source_ja": "true-buddhism.com"
  },
  "chapters": [
    {
      "number": 1,
      "name_vi": "Phẩm Song Yếu",
      "name_ja": "双品",
      "verses": [
        {
          "number": 1,
          "vi": "Tâm dẫn đầu các pháp...",
          "ja": "諸法は意に支配せられ..."
        }
      ]
    }
  ]
}
```

### 5. GitHub Actions Upgrades

| Action | From | To |
|--------|------|----|
| `actions/checkout` | `v4` | `v4` (OK) |
| `dart-lang/setup-dart` | `v1` | `v1` (OK) |
| `vn7n24fzkq/github-profile-summary-cards` | `v0.6.1` | `v0.7.0` |
| `Platane/snk` | `v3` | `v3` (OK) |
| `crazy-max/ghaction-github-pages` | `v3.1.0` | `v4.2.0` |
| New: `actions/setup-python` | — | `v5` (for future Python switch) |

### 6. Code Quality Fixes

- Remove SSL bypass (`badCertificateCallback`)
- Fix variable naming: `file_template` → `fileTemplate` (Dart convention)
- Remove env vars dump (`envVars.forEach` print all secrets — security risk!)

### 7. File Structure

```
bhtri/
├── bin/
│   ├── main.dart          # Updated Dart version
│   └── main.py            # New Python version
├── local_quotes/
│   ├── dhammapada.json    # 423 verses Vi+Ja
│   └── dhammapada.xml     # Same data in XML
├── Template.md            # Updated with 2 quote sections
├── requirements.txt       # Python dependencies
├── pubspec.yaml           # Updated Dart deps
└── .github/workflows/
    └── quote_generator.yml # Updated action versions + Python setup
```

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Meigen API goes down | Fallback chain (yesterday → default message) |
| Scrape data mismatch Vi/Ja | Manual verify verse count per chapter matches |
| `ghaction-github-pages` v3→v4 breaking | Check migration guide before upgrade |
| loiphatday.org structure changes | Data already scraped locally, no runtime dependency |

## Implementation Phases

1. **Phase 1**: Scrape Dhammapada → save JSON + XML (Python script, run once, discard)
2. **Phase 2**: Update `pubspec.yaml` + `Template.md`
3. **Phase 3**: Rewrite `bin/main.dart` (meigen API + dhammapada + fallback)
4. **Phase 4**: Create `bin/main.py` (same logic in Python)
5. **Phase 5**: Update `quote_generator.yml` (action versions + Python setup)
6. **Phase 6**: Test locally + verify

## Unresolved Questions

1. `crazy-max/ghaction-github-pages` v3→v4: need to check migration guide for breaking changes
2. Meigen API field `auther` (typo) — just use as-is from API response
3. `vn7n24fzkq/github-profile-summary-cards` v0.7.0 — need to verify no breaking config changes
