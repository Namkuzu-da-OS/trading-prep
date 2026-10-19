# Trading Prep System

Automated market briefings powered by Claude Code agent teams. Two reports daily: a pre-market morning brief and a post-market end-of-day recap, delivered to your inbox.

## Schedule

Both reports are run manually. Emails go to the address in `.email-to` (git-ignored).

| Report | Typical Time | Command |
|--------|-------------|---------|
| Morning Prep | Before market open | `bash ~/projects/trading-prep/run-morning-prep.sh` |
| EOD Recap | After market close | `bash ~/projects/trading-prep/run-eod-prep.sh` |

## File Inventory

| File | Purpose |
|------|---------|
| `morning-prompt.md` | Morning pre-market research prompt (sequential) |
| `eod-prompt.md` | End-of-day post-market research prompt (9-agent team) |
| `run-morning-prep.sh` | Morning orchestrator: Claude -> pandoc -> email |
| `run-eod-prep.sh` | EOD orchestrator: Claude -> pandoc -> email |
| `templates/email-dark.html5` | Shared dark theme HTML email template |
| `reports/` | Output directory for daily markdown and HTML reports |
| `logs/` | Run logs for debugging and audit trail |
| `PROJECT_TRACKER.md` | This file; documents the system end-to-end |

## How It Works

Both systems follow the same pipeline:

```
cron
  -> run-{morning,eod}-prep.sh
    -> claude -p (reads {morning,eod}-prompt.md)
      -> researches 8 sections sequentially
      -> final report saved as markdown to reports/
    -> pandoc converts markdown to HTML (dark theme)
    -> msmtp emails HTML report to recipient
```

### Morning Pipeline
1. **Cron** fires `run-morning-prep.sh` at 5:00 AM PT on weekdays
2. Claude Code researches 8 sections sequentially (overnight, catalysts, news, blackout, intermarket, breadth, structure, technicals)
3. Report saved as `reports/trading-prep-YYYY-MM-DD.md`
4. Pandoc converts to HTML, msmtp delivers email

### EOD Pipeline
1. **Cron** fires `run-eod-prep.sh` at 2:00 PM PT (5:00 PM ET) on weekdays
2. Claude Code spawns 9 agents focused on session recap, catalysts, and tomorrow prep
3. Report saved as `reports/eod-report-YYYY-MM-DD.md`
4. Pandoc converts to HTML, msmtp delivers email

## Agent Teams

### Morning Team (9 Agents)

| Agent | Role |
|-------|------|
| yesterday-recap | Yesterday's close, overnight futures, Asia/Europe markets, pre-market movers |
| catalysts-calendar | Earnings calendar, economic data, Fed speakers, FOMC proximity, OpEx |
| news-geopolitical | Top market news, geopolitical developments, analyst actions |
| buyback-blackout | Buyback blackout window entry/exit analysis |
| intermarket-sentiment | DXY, yields, oil, gold, VIX, BTC, AAII, Fear & Greed, put/call |
| sector-breadth | Sector ETF performance, advance/decline, breadth divergences |
| market-structure | Short interest, insider buying, IPO lock-ups, dark pool activity |
| technical-setups | RSI divergences, MA tests, Bollinger, MACD, Wyckoff, seasonality |
| fact-checker | Validates all data, resolves contradictions, compiles final report |

### EOD Team (9 Agents)

| Agent | Role |
|-------|------|
| session-recap | Today's close, session character, volume, after-hours movers, internals |
| narrative-catalysts | Primary narrative, economic data reactions, Fed commentary, policy news |
| earnings-review | Today's earnings results, guidance themes, tomorrow's earnings calendar |
| sector-breadth | Sector scoreboard, rotation signals, breadth assessment |
| intermarket-sentiment | DXY, yields, oil, gold, VIX, BTC, credit spreads, sentiment gauges |
| technical-close | Key levels, RSI divergences, VWAP, MA tests, chart patterns, gaps |
| market-structure | Options flow, gamma exposure, dark pool, insider transactions |
| tomorrow-setup | Futures, tomorrow's calendar, scenario analysis, key levels |
| fact-checker | Validates all data, resolves contradictions, compiles final report |

## How to Run Manually

```bash
# Morning report
bash ~/projects/trading-prep/run-morning-prep.sh

# EOD report
bash ~/projects/trading-prep/run-eod-prep.sh

# Just the Claude agent portion (no email):
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude -p "$(cat ~/projects/trading-prep/morning-prompt.md)"
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude -p "$(cat ~/projects/trading-prep/eod-prompt.md)"
```

## How to Check Logs

```bash
# List recent logs
ls -lt ~/projects/trading-prep/logs/ | head -10

# Tail morning log
tail -f ~/projects/trading-prep/logs/prep-$(date +%Y-%m-%d).log

# Tail EOD log
tail -f ~/projects/trading-prep/logs/eod-$(date +%Y-%m-%d).log

# Check for errors across both
grep -i error ~/projects/trading-prep/logs/*-$(date +%Y-%m-%d).log
```

## Email Configuration

- **MTA:** msmtp
- **Provider:** Gmail (app password)
- **Recipient:** the address in `.email-to` (git-ignored)
- **Config file:** `~/.msmtprc`

msmtp config structure:

```
account default
host smtp.gmail.com
port 587
auth on
user <gmail-address>
password <app-password>
from <gmail-address>
tls on
tls_starttls on
```

## Dependencies

| Dependency | Purpose |
|------------|---------|
| `claude-code` | AI agent orchestration (Claude Code CLI) |
| `pandoc` | Markdown to HTML conversion |
| `msmtp` | Lightweight SMTP client for email delivery |

## Troubleshooting

| Problem | Check |
|---------|-------|
| No report generated | Check `logs/` for the day's log; verify cron is running (`crontab -l`) |
| Report generated but no email | Check msmtp config (`msmtp --debug`); verify Gmail app password is valid |
| Partial or empty report | Check Claude Code output in logs; may indicate API rate limits or network issues |
| Cron not firing | Verify timezone (`timedatectl`); check cron daemon (`systemctl status cron`) |
| Claude errors | Ensure `claude` is on PATH in cron environment; check API key is set |
| Pandoc conversion fails | Verify pandoc is installed (`pandoc --version`); check markdown syntax in report |
| Email goes to spam | Add SPF/DKIM records or whitelist sender in recipient's mail client |
| Stale data in report | Agents may have hit rate limits on data sources; check individual agent logs |
| Only some agents report | Run timed out before all agents finished; increase TIMEOUT_SECONDS or reduce agent workload |
