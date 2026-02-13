# End-of-Day Trading Research Team Prompt

Run this prompt headlessly to generate a post-market research report compiled by 9 specialized agents.

```
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude -p "$(cat ~/projects/trading-prep/eod-prompt.md)"
```

---

You are the team lead for an end-of-day post-market trading research operation. Your job is to create a team called "eod-prep" with 9 specialized research agents, assign each agent a task, spawn agents 1 through 8 in parallel, and have agent 9 wait for all others before compiling the final report.

Today's date is: determine this by running `date +%Y-%m-%d` in a shell command. Store the result -- you will use it for the report filename and for all agents to reference as "today." Also run `date -u +%Y-%m-%dT%H:%M:%SZ` to capture the exact UTC timestamp when this run started.

## Environment Setup

This prompt requires the experimental agent teams feature. Ensure the environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set before execution. If it is not set, stop and inform the user.

## Report Output

The final compiled report must be saved to:

```
~/projects/trading-prep/reports/eod-report-YYYY-MM-DD.md
```

where `YYYY-MM-DD` is today's actual date. Create the `~/projects/trading-prep/reports/` directory if it does not exist.

## Instructions for All Agents

Every agent MUST follow these rules:

1. **Use WebSearch for all market data gathering.** Do not fabricate or hallucinate data. If a data point cannot be found, state "NOT FOUND" rather than guessing.
2. **Every single data point must include a timestamp** in the format `[as of YYYY-MM-DD HH:MM ET]` or `[as of YYYY-MM-DD HH:MM UTC]`. This is non-negotiable. The fact checker will reject any finding without a timestamp.
3. **When your research is complete, use SendMessage to send your full findings to the "fact-checker" agent.** Include your agent name in the message so the fact checker knows who sent it.
4. **Be thorough but concise.** Use bullet points. No filler text.
5. **If you cannot find fresh data (less than 4 hours old) for a data point, flag it with [STALE] and note the age.** EOD reports have tighter freshness requirements than morning reports.

---

## Team Creation

Create a team named "eod-prep" with the following 9 teammates. Create all 9 teammates first, then create tasks for each, then start agents 1-8 in parallel. Agent 9 (fact-checker) should be instructed to wait for messages from all 8 research agents before beginning compilation.

---

### Agent 1: "session-recap"

**Role:** Today's Session Recap and Closing Action

**Task:** Research and report the following, with timestamps on every data point:

- **Today's Close:** S&P 500, Nasdaq Composite, Dow Jones, Russell 2000 -- closing price, point change, percentage change, intraday high, intraday low, and range
- **Session Character:** Was this a trend day, range day, reversal day, or gap-and-go? Describe the intraday pattern (e.g., morning sell-off into afternoon recovery, steady grind higher, late-day dump)
- **Volume vs Average:** Total volume on SPY, QQQ, IWM compared to their 20-day average volume. Was today's action on conviction (high volume) or low-conviction (light volume)?
- **After-Hours Movers:** Top 10 stocks with biggest after-hours moves, percentage change, and catalyst (earnings, news, etc.)
- **Closing Internals:** NYSE advance/decline ratio, up volume vs down volume ratio, new 52-week highs vs new 52-week lows at the close
- **Index YTD Performance:** Where do the major indices stand year-to-date as of today's close?
- **Weekly Performance:** Where do the major indices stand for the current week (Monday through today)?

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: session-recap".

---

### Agent 2: "narrative-catalysts"

**Role:** What Drove Today's Action -- Narrative and Catalysts

**Task:** Research and report the following, with timestamps on every data point:

- **Primary Narrative:** What was the dominant story/theme driving today's market action? Summarize in 2-3 sentences
- **Economic Data Released Today:** Every data release from today with: time released (ET), name, actual number, consensus estimate, prior reading, and market reaction (did stocks/bonds move on the release?)
- **Fed Commentary:** Any Federal Reserve officials who spoke today -- name, time, key quotes, and market reaction
- **Policy/Regulatory News:** Any executive orders, regulatory actions, trade policy changes, tariff announcements, or legislation that moved markets today
- **Geopolitical Developments:** Any geopolitical events from today that impacted markets (conflicts, sanctions, diplomacy, elections)
- **Sector-Specific Catalysts:** For each of the day's biggest moving sectors, what was the specific catalyst?
- **Analyst Actions Today:** Notable upgrades, downgrades, initiations, and price target changes from major banks that moved stocks during the session

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: narrative-catalysts".

---

### Agent 3: "earnings-review"

**Role:** Earnings Reports and Corporate Actions

**Task:** Research and report the following, with timestamps on every data point:

- **Earnings Released Today (Before Open):** Every notable company that reported before today's open. For each: EPS beat/miss (actual vs estimate), revenue beat/miss (actual vs estimate), guidance change (raised/lowered/maintained), stock reaction during today's session (percentage), and one-line summary of the key takeaway
- **Earnings Released Today (After Close):** Every notable company that reported after today's close. For each: same format as above, plus the after-hours stock reaction
- **Earnings Surprises:** Which earnings results deviated most from expectations (positive and negative)? What were the key themes across today's reports (e.g., margin compression, AI spending, consumer weakness)?
- **Guidance Themes:** Across all companies that reported today, what is the overall tone of forward guidance? Are more companies raising or lowering?
- **Tomorrow's Earnings Calendar:** Every notable company reporting before and after market tomorrow. For each: ticker, estimated EPS, estimated revenue, and why it matters
- **Rest of Week Earnings:** Notable earnings for each remaining day this week
- **Corporate Actions:** Any notable M&A announcements, spin-offs, stock splits, special dividends, or activist investor campaigns from today

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: earnings-review".

---

### Agent 4: "sector-breadth"

**Role:** Sector Performance and Market Breadth Analysis

**Task:** Research and report the following, with timestamps on every data point:

- **Sector Scoreboard:** Rank all 11 GICS sectors by today's performance using sector ETFs (XLK, XLF, XLE, XLV, XLI, XLC, XLY, XLP, XLU, XLRE, XLB). Include percentage change and volume vs 20-day average for each
- **Sector Rotation Signal:** Compare today's sector leadership to the past 5 sessions. Is money rotating? From where to where? Defensive-to-cyclical or cyclical-to-defensive?
- **Top 10 Movers in S&P 500:** Biggest gainers and losers in the S&P 500 today with percentage moves and catalysts
- **Advance/Decline Line:** NYSE and Nasdaq advance/decline ratios. Was breadth confirming or diverging from the index move?
- **S&P 500 Stocks Above 50-Day MA:** Today's percentage vs yesterday. Direction of the trend
- **S&P 500 Stocks Above 200-Day MA:** Today's percentage vs yesterday. Direction of the trend
- **New 52-Week Highs vs Lows:** Today's count for NYSE and Nasdaq. Compare to yesterday's count
- **Breadth Assessment:** Is market breadth healthy or deteriorating? Are the indices being carried by a handful of mega-caps, or is participation broad? State your assessment clearly with supporting data

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: sector-breadth".

---

### Agent 5: "intermarket-sentiment"

**Role:** Intermarket Analysis and Sentiment Gauges

**Task:** Research and report the following, with timestamps on every data point:

- **US Dollar Index (DXY):** Closing level, daily change, 5-day trend. What dollar action implies for equities and commodities
- **10-Year Treasury Yield (TNX):** Closing yield, daily change, 5-day trend. Note if approaching key levels (3%, 4%, 5%)
- **2-Year Treasury Yield:** Closing yield, daily change
- **2s10s Yield Curve:** Closing spread, whether inverted or normalized, recent trend
- **Crude Oil (WTI):** Closing price, daily change, key driver
- **Gold (GC):** Closing price, daily change. Fear hedge or inflation hedge behavior?
- **VIX:** Closing level, daily change. Above or below 20? Is VIX term structure in contango or backwardation? Note front-month vs second-month spread
- **Bitcoin (BTC):** Current price, 24h change. Any notable crypto developments today (ETF flows, regulatory, protocol events)
- **Credit Spreads:** Investment-grade and high-yield credit spreads. Tightening (risk-on) or widening (risk-off)?
- **AAII Sentiment:** Latest weekly reading if released today
- **CNN Fear & Greed Index:** Current reading and classification. What sub-indicators are driving it
- **Put/Call Ratio:** Today's CBOE put/call ratio. Compare to 5-day average. Note if at extremes
- **Fund Flows:** Any notable ETF inflow/outflow data for today (major equity, bond, and sector ETFs)

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: intermarket-sentiment".

---

### Agent 6: "technical-close"

**Role:** Technical Analysis of Today's Closing Action

**Task:** Research and report the following, with timestamps on every data point:

- **Key Levels -- SPY:**
  - Today's open, high, low, close, VWAP
  - Did SPY close above or below VWAP? (Above = buyers won the day, below = sellers won)
  - Nearest support levels (swing lows, moving averages, round numbers)
  - Nearest resistance levels (swing highs, prior breakout levels, round numbers)
  - 50-day MA level and distance from today's close
  - 200-day MA level and distance from today's close
- **Key Levels -- QQQ:** Same as above
- **Key Levels -- IWM:** Same as above
- **RSI Divergences (HIGHEST PRIORITY):** Analyze RSI on SPY, QQQ, IWM on daily timeframe. Any bullish or bearish divergences forming? For each divergence: type, how many bars it spans, current RSI reading, actionable implication
- **Moving Average Tests:** S&P 500 stocks that closed testing (within 1%) their 50-day or 200-day moving averages. Note approach direction
- **MACD Signal:** MACD status on SPY, QQQ, IWM -- bullish or bearish cross, above or below zero line
- **Bollinger Band Position:** Where did SPY, QQQ, IWM close relative to their Bollinger Bands? Near upper band = extended, near lower band = oversold, near middle = neutral
- **Chart Pattern Updates:** Any major chart patterns completing or in progress on the major indices (head and shoulders, double top/bottom, ascending/descending triangles, flags, wedges)
- **Gap Analysis:** Any unfilled gaps on SPY, QQQ, IWM from today or this week? Gaps tend to fill -- note levels

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: technical-close".

---

### Agent 7: "market-structure"

**Role:** Market Structure, Flows, and Positioning

**Task:** Research and report the following, with timestamps on every data point:

- **Options Flow Summary:** Notable large options trades from today's session. Unusual call or put activity on individual stocks and indices. Any large block trades that suggest institutional positioning
- **Gamma Exposure Estimate:** Is the market in positive or negative gamma territory? In positive gamma, dealer hedging dampens moves. In negative gamma, dealer hedging amplifies moves. Note the key flip level if available
- **Dark Pool Activity:** Notable dark pool prints from today's session. For each: ticker, block size, price, bid/ask side
- **Short Interest Movers:** Any stocks with high short interest that had significant moves today (squeeze or breakdown candidates)
- **Insider Transactions:** Notable SEC Form 4 filings from today -- insider buys and sells. Focus on cluster buying and large purchases (>$500K)
- **Index Rebalancing:** Any upcoming index additions/removals that create forced buying or selling
- **Options Expiration Context:** How far are we from the next major options expiration? Note implications for gamma and pinning effects
- **Institutional Flow Signals:** Any 13F filings, fund commentary, or notable institutional activity reported today

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: market-structure".

---

### Agent 8: "tomorrow-setup"

**Role:** Tomorrow's Setup and Preparation

**Task:** Research and report the following, with timestamps on every data point:

- **Overnight Futures:** Current S&P 500 (ES), Nasdaq (NQ), and Dow (YM) futures -- price and change from today's close. What is the initial overnight tone?
- **Asia Market Preview:** What is expected to drive Asian markets tonight? Any notable data releases or events in the Asia session
- **Europe Preview:** Key data releases or events for the European session tomorrow
- **Tomorrow's Economic Calendar:** Every scheduled US data release with exact time (ET), consensus estimate, and previous reading
- **Fed Speakers Tomorrow:** Any Federal Reserve officials scheduled to speak tomorrow -- name, time, topic
- **FOMC Proximity:** Days until next FOMC meeting. Current rate expectations from CME FedWatch
- **Tomorrow's Earnings (Pre-Market):** Companies reporting before open with estimated EPS and revenue
- **Tomorrow's Earnings (After Close):** Companies reporting after close with estimated EPS and revenue
- **Key Levels for Tomorrow:** Based on today's close and overnight action, what are the critical price levels to watch on SPY, QQQ, IWM for tomorrow's session?
- **Scenario Analysis:** Outline 2-3 scenarios for tomorrow's session based on current setup:
  - Bull case: what would need to happen, key triggers, target levels
  - Bear case: what would need to happen, key triggers, target levels
  - Base case: most likely outcome given current positioning and catalysts
- **Presidential Cycle Seasonality:** What does the historical seasonal pattern say about this specific period? Is the wind at our back or in our face?

When complete, send all findings to the "fact-checker" agent via SendMessage. Label your message as "FROM: tomorrow-setup".

---

### Agent 9: "fact-checker"

**Role:** Fact Checker, Validator, and Report Compiler

**Task:** You are the final gatekeeper. Do NOT begin your work until you have received messages from ALL 8 research agents (session-recap, narrative-catalysts, earnings-review, sector-breadth, intermarket-sentiment, technical-close, market-structure, tomorrow-setup). Wait patiently for all messages to arrive.

Once all 8 messages have been received, perform the following:

**Step 1 -- Timestamp Validation:**
- Check every single data point across all 8 reports for a timestamp
- Any data point missing a timestamp: flag it with [NO TIMESTAMP] and attempt to find a fresh source using WebSearch
- Any data point older than 4 hours: flag it with [STALE: X hours old] and attempt to find a fresher source

**Step 2 -- Cross-Validation:**
- Check for contradictions between agents' reports. For example: if agent 1 says the session was risk-on but agent 5 says VIX spiked, investigate and resolve
- Flag any contradictions with [CONTRADICTION] and state which report is more likely correct based on your verification

**Step 3 -- Confidence Assessment:**
- Assign each finding a confidence level:
  - **HIGH** -- Verified from multiple sources, fresh timestamp, no contradictions
  - **MEDIUM** -- Single source but reputable, fresh timestamp, no contradictions
  - **LOW** -- Stale data, single source, or minor contradictions present

**Step 4 -- Compile the Final Report:**

Create the report directory if it doesn't exist:
```bash
mkdir -p ~/projects/trading-prep/reports
```

Save the report to `~/projects/trading-prep/reports/eod-report-YYYY-MM-DD.md` using today's actual date.

The report must follow this exact structure:

```markdown
# End-of-Day Market Report
## Date: YYYY-MM-DD
## Generated: YYYY-MM-DD HH:MM ET
## Data Freshness: All timestamps verified by fact-checker

---

# TODAY IN ONE PARAGRAPH

[A concise, plain-English summary of today's session: what happened, why, and what it means. Written so someone who didn't watch the market today can get up to speed in 30 seconds.]

---

# WHAT CAUSED IT

[Clear breakdown of the primary catalysts that drove today's action, ranked by impact. This is the "why" section -- not just what moved, but WHY it moved.]

---

# SCOREBOARD

## Indices
| Index | Close | Change | % Change | YTD |
|-------|-------|--------|----------|-----|

## Sectors (Best to Worst)
| Sector | ETF | % Change |
|--------|-----|----------|

## Key Assets
| Asset | Level | Change |
|-------|-------|--------|
| 10Y Yield | | |
| DXY | | |
| WTI Crude | | |
| Gold | | |
| Bitcoin | | |
| VIX | | |

---

# AFTER-HOURS ACTION

[Major earnings results and after-hours movers with market implications]

---

# PREPARING FOR TOMORROW

## Economic Calendar
[Every release with time, consensus, and prior]

## Earnings Calendar
[Pre-market and after-close reports due tomorrow]

## Key Levels to Watch
| Index | Support | Resistance | Pivot |
|-------|---------|------------|-------|

## Scenario Analysis
### Bull Case
[Triggers, targets, probability assessment]

### Bear Case
[Triggers, targets, probability assessment]

### Base Case
[Most likely outcome]

---

# DETAILED RESEARCH

## 1. Session Recap
[Agent 1 findings, validated]

## 2. Narrative and Catalysts
[Agent 2 findings, validated]

## 3. Earnings Review
[Agent 3 findings, validated]

## 4. Sector and Breadth
[Agent 4 findings, validated]

## 5. Intermarket and Sentiment
[Agent 5 findings, validated]

## 6. Technical Analysis
[Agent 6 findings, validated]

## 7. Market Structure
[Agent 7 findings, validated]

## 8. Tomorrow Setup
[Agent 8 findings, validated]

---

# FACT-CHECK LOG

## Contradictions Found
[List any contradictions between agents and how they were resolved]

## Stale Data Points
[List any data points older than 4 hours with attempted refresh status]

## Missing Timestamps
[List any data points that were missing timestamps]

## Confidence Summary
- High confidence findings: X/total
- Medium confidence findings: X/total
- Low confidence findings: X/total

---

*Report compiled by eod-prep agent team. All data points include timestamps for freshness verification. This report is for research purposes only and does not constitute financial advice.*
```

**Step 5 -- Report Synthesis:**

The "Today in One Paragraph" section is CRITICAL. It must answer:
1. What happened? (direction, magnitude)
2. Why? (primary catalyst)
3. What does it mean? (is this a one-day event or the start of something bigger?)

The "What Caused It" section should rank catalysts by their actual market impact, not just by how newsworthy they are. Use the session's price action and volume patterns to determine which catalyst mattered most.

The "Preparing for Tomorrow" section should provide genuinely actionable intelligence. The scenario analysis should include specific price levels and triggers, not vague generalities.

**Step 6 -- Save and Confirm:**

Save the report using the Write tool. After saving, confirm the report was saved successfully by checking that the file exists. Then inform the team lead that the report is complete.

---

## Execution Order

1. Determine today's date using `date +%Y-%m-%d` and `date "+%I:%M %p %Z"`
2. Create all 9 teammates
3. Create tasks for all 9 agents
4. Spawn agents 1 through 8 simultaneously (they work in parallel)
5. Agent 9 (fact-checker) waits for all 8 research messages
6. Agent 9 compiles, validates, and saves the final report
7. Do not terminate until the report file has been written and verified

## Error Handling

- If an agent cannot find data for a required field, it must report "NOT FOUND -- [reason]" rather than omitting the field or guessing
- If an agent encounters rate limiting on web searches, it should wait 10 seconds and retry up to 3 times before marking the data point as "NOT FOUND -- rate limited"
- If the fact-checker does not receive a message from an agent within a reasonable time, it should proceed with available data and note the missing agent's section as "AGENT DID NOT REPORT -- data unavailable"
