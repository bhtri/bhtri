# Phase 1: Scrape Dhammapada Data

## Goal
Extract 423 verses (26 chapters) from Vietnamese + Japanese sources, save as `local_quotes/dhammapada.json` + `local_quotes/dhammapada.xml`.

## Sources

| Language | URL | Structure |
|----------|-----|-----------|
| Vietnamese | `loiphatday.org/kinh-phap-cu-{NN}-pham-{slug}` | 26 pages, 1 per chapter |
| Japanese | `true-buddhism.com/sutra/dhammapada/` | Single page, all 423 verses |

## Steps

### 1.1 Write temporary Python scrape script
- Use `requests` + `BeautifulSoup`
- Scrape Vietnamese: 26 HTTP requests (1 per chapter page)
- Scrape Japanese: 1 HTTP request (single page)
- Parse verse numbers, text, chapter info
- **Important**: Match Vi verse N with Ja verse N — same numbering

### 1.2 Generate output files
- `local_quotes/dhammapada.json` — primary, used by code
- `local_quotes/dhammapada.xml` — secondary, same data

### 1.3 Verify data integrity
- Total: 423 verses across 26 chapters
- Each verse has: number, vi text, ja text
- Each chapter has: number, name_vi, name_ja, verses array
- JSON and XML must be identical in content and order

### 1.4 Discard scrape script
- Script is temporary — only output data matters
- Do NOT commit the scrape script

## JSON Structure

```json
{
  "metadata": {
    "title_vi": "Kinh Phap Cu",
    "title_ja": "法句経（ダンマパダ）",
    "total_verses": 423,
    "total_chapters": 26,
    "source_vi": "loiphatday.org",
    "source_ja": "true-buddhism.com"
  },
  "chapters": [
    {
      "number": 1,
      "name_vi": "Pham Song Yeu",
      "name_ja": "双品",
      "verses": [
        { "number": 1, "vi": "...", "ja": "..." }
      ]
    }
  ]
}
```

## XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dhammapada>
  <metadata>
    <title_vi>Kinh Phap Cu</title_vi>
    <title_ja>法句経（ダンマパダ）</title_ja>
    <total_verses>423</total_verses>
    <total_chapters>26</total_chapters>
  </metadata>
  <chapters>
    <chapter number="1" name_vi="Pham Song Yeu" name_ja="双品">
      <verse number="1">
        <vi>...</vi>
        <ja>...</ja>
      </verse>
    </chapter>
  </chapters>
</dhammapada>
```

## Validation Checklist

- [ ] 26 chapters scraped from Vi source
- [ ] 26 chapters scraped from Ja source
- [ ] 423 total verses in each source
- [ ] Verse count per chapter matches between Vi and Ja
- [ ] JSON and XML files contain identical data
- [ ] UTF-8 encoding correct (Vietnamese diacritics + Japanese kanji)
- [ ] Scrape script deleted after successful extraction

## Chapter Reference

| # | Vietnamese | Japanese | Verses |
|---|-----------|----------|--------|
| 1 | Pham Song Yeu | 双品 | 1-20 |
| 2 | Pham Khong Phong Dat | 不放逸品 | 21-32 |
| 3 | Pham Tam | 心品 | 33-43 |
| 4 | Pham Hoa | 花品 | 44-59 |
| 5 | Pham Ngu | 愚品 | 60-75 |
| 6 | Pham Hien Tri | 賢品 | 76-89 |
| 7 | Pham A-La-Han | 阿羅漢品 | 90-99 |
| 8 | Pham Ngan | 千品 | 100-115 |
| 9 | Pham Ac | 悪品 | 116-128 |
| 10 | Pham Hinh Phat | 刀杖品 | 129-145 |
| 11 | Pham Gia | 老品 | 146-156 |
| 12 | Pham Tu Nga | 自己品 | 157-166 |
| 13 | Pham The Gian | 世品 | 167-178 |
| 14 | Pham Phat Da | 仏陀品 | 179-196 |
| 15 | Pham An Lac | 安楽品 | 197-208 |
| 16 | Pham Hy Ai | 愛好品 | 209-220 |
| 17 | Pham Phan No | 忿怒品 | 221-234 |
| 18 | Pham Cau Ue | 垢穢品 | 235-255 |
| 19 | Pham Phap Tru | 法住品 | 256-272 |
| 20 | Pham Dao | 道品 | 273-289 |
| 21 | Pham Tap Luc | 雑品 | 290-305 |
| 22 | Pham Dia Nguc | 地獄品 | 306-319 |
| 23 | Pham Voi | 象品 | 320-333 |
| 24 | Pham Tham Ai | 愛欲品 | 334-359 |
| 25 | Pham Ty Kheo | 比丘品 | 360-382 |
| 26 | Pham Ba La Mon | 婆羅門品 | 383-423 |
