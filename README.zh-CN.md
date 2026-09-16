# ops-github-weekly

> 零依赖的 GitHub 每周报告生成器——自动抓取热榜新项目 + 全站 Star 总榜，每周一早上自动生成。输出 Markdown + 网页双格式。

[English](README.md) | 简体中文

## 它是什么

每周一早上 9:00（或手动触发），自动从 GitHub Search API 抓取两份数据：

1. **近 7 天最热门新项目 Top 10**（高 star 新仓库，trending 近似）
2. **全站 Star 总榜 Top 10**

并生成两份报告：

- `YYYY-MM-DD.md` —— Markdown 版，可贴进 Wiki / 公众号
- `YYYY-MM-DD.html` —— 网页版，双击浏览器打开即看

真实输出见 [sample-report.md](sample-report.md)。

## 快速开始

```bash
bash github-weekly.sh
```

要求：macOS / Linux，自带 `curl` + `python3` 即可。**无需 API Token**。

### 定时运行（macOS launchd）

```bash
cp com.len.github-weekly.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.len.github-weekly.plist
```

### 定时运行（Linux crontab）

```bash
crontab -e
# 每周一早上 9:00
0 9 * * 1 /path/to/ops-github-weekly/github-weekly.sh
```

## 说明

- 使用 GitHub Search API **未认证**模式，限额 60 次/小时（本脚本每次消耗 2 次），个人使用绰绰有余。需要更高频率可自行加入 [Personal Access Token](https://github.com/settings/tokens)。
- 基于这份数据的运维/安全视角中文解读，发布在作者的微信公众号——数据和解读，各取所需。

## License

MIT
