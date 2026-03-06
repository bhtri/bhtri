# Phase 5: Update GitHub Actions

## Goal
Split into 2 separate workflow files (Dart + Python). Upgrade action versions. Only 1 active at a time.

## 5.1 File Structure

```
.github/workflows/
  quote_generator_dart.yml      # Dart version (DEFAULT - enabled)
  quote_generator_python.yml    # Python version (disabled by default)
```

Delete old `quote_generator.yml` after creating the 2 new files.

## 5.2 Version Upgrades (both files share these)

| Action | From | To | Breaking? |
|--------|------|----|-----------|
| `vn7n24fzkq/github-profile-summary-cards` | `v0.6.1` | `v0.7.0` | Check changelog |
| `crazy-max/ghaction-github-pages` | `v3.1.0` | `v4.2.0` | Yes — check migration |

**Others stay**: checkout@v4, Platane/snk@v3 — already latest major.

## 5.3 quote_generator_dart.yml (DEFAULT - enabled)

```yaml
name: quote_generator_dart

on:
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * *"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: jasineri/gitartwork@v1
        with:
          user_name: ${{ github.repository_owner }}
          text: WDVQMJ7377

      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: dart analyze
      - run: dart bin/main.dart

      - name: Update README.md
        run: |
          git config user.email "16353896+bhtri@users.noreply.github.com"
          git config user.name "bhtri"
          git add .
          git commit -m "Updated README.md" || echo "No changes to commit"
          git pull --rebase
          git push

      - uses: vn7n24fzkq/github-profile-summary-cards@v0.7.0
        env:
          GITHUB_TOKEN: ${{ secrets.MY_SECRET }}
        with:
          USERNAME: ${{ github.repository_owner }}

      - uses: Platane/snk@v3
        with:
          github_user_name: ${{ github.repository_owner }}
          outputs: |
            dist/github-contribution-grid-snake.svg
            dist/github-contribution-grid-snake-dark.svg?palette=github-dark
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: crazy-max/ghaction-github-pages@v4.2.0
        with:
          target_branch: output
          build_dir: dist
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 5.4 quote_generator_python.yml (disabled by default)

```yaml
name: quote_generator_python

on:
  workflow_dispatch:
  # schedule:            # <-- commented out = disabled from auto-run
  #   - cron: "0 0 * * *"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: jasineri/gitartwork@v1
        with:
          user_name: ${{ github.repository_owner }}
          text: WDVQMJ7377

      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: python bin/main.py

      - name: Update README.md
        run: |
          git config user.email "16353896+bhtri@users.noreply.github.com"
          git config user.name "bhtri"
          git add .
          git commit -m "Updated README.md" || echo "No changes to commit"
          git pull --rebase
          git push

      - uses: vn7n24fzkq/github-profile-summary-cards@v0.7.0
        env:
          GITHUB_TOKEN: ${{ secrets.MY_SECRET }}
        with:
          USERNAME: ${{ github.repository_owner }}

      - uses: Platane/snk@v3
        with:
          github_user_name: ${{ github.repository_owner }}
          outputs: |
            dist/github-contribution-grid-snake.svg
            dist/github-contribution-grid-snake-dark.svg?palette=github-dark
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: crazy-max/ghaction-github-pages@v4.2.0
        with:
          target_branch: output
          build_dir: dist
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 5.5 How to Switch Between Dart and Python

**Method: Toggle `schedule` trigger**

To switch from Dart to Python:
1. Edit `quote_generator_dart.yml`: comment out the `schedule` block
2. Edit `quote_generator_python.yml`: uncomment the `schedule` block
3. Push changes

Both files always keep `workflow_dispatch` — so either can be triggered manually anytime from GitHub Actions tab (Actions > select workflow > Run workflow).

**No need to disable workflows via GitHub UI** — just toggle the `schedule` cron.

## 5.6 ghaction-github-pages v3 to v4 Migration

v4 primarily updates Node.js runtime. `target_branch` and `build_dir` params backwards compatible.

## 5.7 Cleanup

- Delete `quote_generator.yml` (old file)
- Remove `TEST_REPO_SECRET`/`TEST_ENV_TOKEN` env vars (unused by new code)

## Validation

- [ ] Both YAML files valid syntax
- [ ] Action versions updated in both files
- [ ] Dart workflow has `schedule` enabled
- [ ] Python workflow has `schedule` commented out
- [ ] Both have `workflow_dispatch` enabled
- [ ] Old `quote_generator.yml` deleted
- [ ] Manual trigger test via workflow_dispatch for Dart version
