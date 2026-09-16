# ops-github-weekly

> A zero-dependency weekly GitHub report generator — hottest new repos + all-time star chart, auto-delivered every Monday morning. Markdown + HTML output.

English | [简体中文](README.zh-CN.md)

## What it does

Every Monday at 9:00 (or on demand), it automatically fetches two datasets from the GitHub Search API:

1. **Top 10 hottest NEW repositories** created in the last 7 days (high-star new repos, trending approximation)
2. **Top 10 all-time star champions**

and generates two reports:

- `YYYY-MM-DD.md` — Markdown, ready for your Wiki / newsletter
- `YYYY-MM-DD.html` — a clean web page, double-click to view

See [sample-report.md](sample-report.md) for a real output.

## Quick start

```bash
bash github-weekly.sh
```

Requirements: macOS / Linux with `curl` + `python3` (both preinstalled on most systems). No API token needed.

### Schedule it (macOS launchd)

```bash
cp com.len.github-weekly.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.len.github-weekly.plist
```

### Schedule it (Linux crontab)

```bash
crontab -e
# every Monday 9:00
0 9 * * 1 /path/to/ops-github-weekly/github-weekly.sh
```

## Notes

- Uses the GitHub Search API in **unauthenticated** mode (60 req/hour limit; this script consumes 2 per run) — plenty for personal use. Add your own [Personal Access Token](https://github.com/settings/tokens) if you need more.
- Weekly ops/security-focused commentary on this data is published (in Chinese) on the author's WeChat account 「小薅薅」 — data and interpretation, take your pick.

## License

MIT
