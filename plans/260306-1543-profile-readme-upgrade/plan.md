---
status: pending
slug: profile-readme-upgrade
created: 2026-03-06
brainstorm: ../reports/brainstorm-260306-1543-profile-readme-upgrade.md
phases: 6
---

# Plan: Profile README Upgrade

## Overview

Replace dead quotable.io API with Japanese Meigen API + bilingual Dhammapada (Kinh Phap Cu), upgrade all dependencies, dual Dart+Python implementation.

## Phases

| # | Phase | Effort | Priority | File |
|---|-------|--------|----------|------|
| 1 | Scrape Dhammapada data | Medium | Critical | [phase-1-scrape-dhammapada.md](phase-1-scrape-dhammapada.md) |
| 2 | Update configs + Template | Low | High | [phase-2-update-configs-template.md](phase-2-update-configs-template.md) |
| 3 | Rewrite main.dart | High | Critical | [phase-3-rewrite-main-dart.md](phase-3-rewrite-main-dart.md) |
| 4 | Create main.py | Medium | High | [phase-4-create-main-py.md](phase-4-create-main-py.md) |
| 5 | Split + Update GitHub Actions (2 workflows) | Low | High | [phase-5-update-github-actions.md](phase-5-update-github-actions.md) |
| 6 | Test + Verify | Low | Critical | [phase-6-test-verify.md](phase-6-test-verify.md) |

## Dependency Chain

```
Phase 1 (data) ──┐
                  ├──→ Phase 3 (dart) ──┐
Phase 2 (config) ─┤                     ├──→ Phase 6 (test)
                  ├──→ Phase 4 (python) ─┤
                  └──→ Phase 5 (actions) ┘
```

## Key Decisions

- Meigen API: `meigen.doodlenote.net/api/json.php?c=1` (no `e=1`)
- Dhammapada: local JSON+XML, random selection daily
- Code reads JSON (simpler), XML as backup/alternative format
- Scrape script: Python, temporary (discard after data extracted)
- Fallback: API fail → yesterday's README quote → "本日サーバーが混雑しています"
