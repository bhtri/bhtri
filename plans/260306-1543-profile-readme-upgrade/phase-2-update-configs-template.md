# Phase 2: Update Configs + Template

## Goal
Upgrade Dart dependencies, redesign Template.md with 2 quote sections.

## 2.1 Update pubspec.yaml

```yaml
name: bhtri
publish_to: none

environment:
  sdk: ^3.4.0

dev_dependencies:
  test: any
dependencies:
  http: ^1.6.0
  intl: ^0.20.0
```

## 2.2 Update Template.md

Replace the single quote section (lines 30-44) with dual quote sections:

**Current:**
```
### **{%TITLE%}**
<p>...<q>{%QUOTE%}</q>...</p>
<p>{%AUTHOR%}</p>
```

**New:**
```markdown
### **{%TITLE%}**

<table>
<tr><td>

**🌸 名言 (Meigen)**

> {%MEIGEN_QUOTE%}

<p align="right"><b>— {%MEIGEN_AUTHOR%}</b></p>

</td></tr>
<tr><td>

**📿 Kinh Phap Cu (Dhammapada)**

> {%DHAMMAPADA_VI%}
>
> *{%DHAMMAPADA_JA%}*

<p align="right"><b>— {%DHAMMAPADA_CHAPTER%}, Ke {%DHAMMAPADA_VERSE%}</b></p>

</td></tr>
</table>
```

**Design rationale**: Using `<table>` with single column creates visual card-like separation. Blockquotes (`>`) for quote text. Italic for Japanese translation. Right-aligned bold for attribution.

## New Placeholders

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{%TITLE%}` | Date formatted | `2026年03月06日` |
| `{%MEIGEN_QUOTE%}` | Meigen API `meigen` field | `たとえ世界が滅ぶとも、正義は遂げよ。` |
| `{%MEIGEN_AUTHOR%}` | Meigen API `auther` field | `フェルディナンド一世` |
| `{%DHAMMAPADA_VI%}` | Local JSON `vi` field | `Tam dan dau cac phap...` |
| `{%DHAMMAPADA_JA%}` | Local JSON `ja` field | `諸法は意に支配せられ...` |
| `{%DHAMMAPADA_CHAPTER%}` | Chapter name (Vi) | `Pham Song Yeu` |
| `{%DHAMMAPADA_VERSE%}` | Verse number | `1` |

## 2.3 Create requirements.txt

```
requests>=2.31.0
```

Minimal — only `requests` for HTTP in Python version. JSON/random/datetime are stdlib.

## Validation

- [ ] `dart pub get` succeeds with new pubspec.yaml
- [ ] Template.md has all 7 placeholders
- [ ] No old placeholders remain ({%QUOTE%}, {%AUTHOR%})
- [ ] requirements.txt created
