#!/bin/bash
# GitHub 每周报告生成器：近7天热门新项目 Top10 + 全站 Star 总榜 Top10
# 每周一 09:00 由 launchd (com.len.github-weekly) 调用；也可手动运行: bash github-weekly.sh
set -u
OUT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$OUT_DIR/error.log"
mkdir -p "$OUT_DIR"
SINCE=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d) || exit 1

TMP1=$(mktemp) || exit 1
TMP2=$(mktemp)
trap 'rm -f "$TMP1" "$TMP2"' EXIT

fetch() { # $1=url $2=outfile
  curl -sS -m 30 -H "Accept: application/vnd.github+json" -H "User-Agent: weekly-report" "$1" -o "$2" || return 1
  python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if 'items' in d else 1)" "$2" 2>/dev/null || return 1
}

if ! fetch "https://api.github.com/search/repositories?q=created:%3E${SINCE}&sort=stars&order=desc&per_page=10" "$TMP1" \
   || ! fetch "https://api.github.com/search/repositories?q=stars:%3E100000&sort=stars&order=desc&per_page=10" "$TMP2"; then
  echo "[$(date '+%F %T')] 拉取失败(网络或API限额), 本次跳过" >> "$LOG"
  exit 1
fi

NEW_JSON="$TMP1" ALL_JSON="$TMP2" OUT_DIR="$OUT_DIR" python3 - <<'EOF'
import json, os, datetime, html
new = json.load(open(os.environ['NEW_JSON']))
allt = json.load(open(os.environ['ALL_JSON']))
today = datetime.date.today()
since = today - datetime.timedelta(days=7)
esc = lambda s: html.escape(str(s or ''))

def rows(items):
    return [(i, r['full_name'], r['stargazers_count'], r.get('language') or '-', (r.get('description') or '')[:80])
            for i, r in enumerate(items[:10], 1)]
r_new, r_all = rows(new['items']), rows(allt['items'])

# ---- Markdown 版 ----
L = [f"# GitHub 周报（生成于 {today.isoformat()}）", "\n> 数据来源: GitHub Search API（未认证，限额 60 次/小时，本报告消耗 2 次）"]
def md_sec(title, rs):
    out = [f"\n## {title}\n", "| # | 项目 | Stars | 语言 | 简介 |", "|---|------|-------|------|------|"]
    for i, name, stars, lang, desc in rs:
        out.append(f"| {i} | [{name}](https://github.com/{name}) | {stars:,} | {lang} | {esc(desc[:60]).replace('|', '/')} |")
    return out
L += md_sec(f"一、近7天最热门新项目（{since} 之后新建、star Top 10，trending 近似）", r_new)
L += md_sec("二、全站 Star 总榜 Top 10", r_all)
open(os.path.join(os.environ['OUT_DIR'], f"{today.isoformat()}.md"), 'w').write('\n'.join(L) + '\n')

# ---- HTML 版（双击即可在浏览器打开）----
def html_sec(title, rs):
    tr = "\n".join(
        f"<tr><td>{i}</td><td><a href='https://github.com/{name}'>{esc(name)}</a></td>"
        f"<td class='n'>{stars:,}</td><td>{esc(lang)}</td><td>{esc(desc)}</td></tr>"
        for i, name, stars, lang, desc in rs)
    return f"<h2>{esc(title)}</h2><table><tr><th>#</th><th>项目</th><th>Stars</th><th>语言</th><th>简介</th></tr>{tr}</table>"

page = f"""<!DOCTYPE html><html lang="zh"><head><meta charset="utf-8">
<title>GitHub 周报 {today.isoformat()}</title><style>
body{{font-family:-apple-system,'PingFang SC',sans-serif;max-width:960px;margin:32px auto;padding:0 16px;color:#1f2328}}
h1{{font-size:26px}} h2{{font-size:19px;margin-top:32px}}
table{{border-collapse:collapse;width:100%;font-size:14px}}
th,td{{border:1px solid #d0d7de;padding:7px 10px;text-align:left;vertical-align:top}}
th{{background:#f6f8fa}} tr:nth-child(even){{background:#fbfbfc}}
td.n{{text-align:right;font-variant-numeric:tabular-nums}}
a{{color:#0969da;text-decoration:none}} a:hover{{text-decoration:underline}}
.note{{color:#656d76;font-size:13px;margin-top:28px}}
</style></head><body>
<h1>GitHub 周报 <small style="font-size:15px;color:#656d76">{today.isoformat()}</small></h1>
{html_sec(f"一、近7天最热门新项目（{since} 之后新建、star Top 10，trending 近似）", r_new)}
{html_sec("二、全站 Star 总榜 Top 10", r_all)}
<p class="note">数据来源: GitHub Search API（未认证，限额 60 次/小时，本报告消耗 2 次）。「热门」为近7天新建项目按 star 数近似 trending。</p>
</body></html>"""
html_path = os.path.join(os.environ['OUT_DIR'], f"{today.isoformat()}.html")
open(html_path, 'w').write(page)
print(html_path)
EOF
TODAY=$(date +%F)
if [ -f "$OUT_DIR/$TODAY.html" ]; then
    (command -v open >/dev/null && open "$OUT_DIR/$TODAY.html") || (command -v xdg-open >/dev/null && xdg-open "$OUT_DIR/$TODAY.html") || true
    echo "[$(date '+%F %T')] 报告已生成并尝试打开: $TODAY.html" >> "$LOG"
else
    echo "[$(date '+%F %T')] 生成失败" >> "$LOG"
    exit 1
fi
