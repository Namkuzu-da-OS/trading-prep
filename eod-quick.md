You are a market research analyst. Today's date is: determine this by running `date +%Y-%m-%d`. Your job is to produce a comprehensive end-of-day market report.

Spin up 4 research agents in parallel using the Task tool, then compile their findings into a single report.

## Agent 1: Major Index & Sector Performance
Research today's US stock market performance:
- Major index closes: S&P 500, Nasdaq, Dow, Russell 2000 (price, point change, % change)
- Biggest sector declines and gains
- Worst and best performing individual stocks with reasons
- Notable volume or breadth data

## Agent 2: Catalysts — What Caused Today's Moves
Research what drove today's market action:
- Economic data releases today (jobs, inflation, GDP, etc.) with actual vs estimate
- Federal Reserve news or speeches
- Geopolitical events (tariffs, trade wars, conflicts)
- Surprising earnings reports or guidance
- Policy announcements from the White House or Congress
- Identify the PRIMARY catalyst and rank all others by impact

## Agent 3: Global Markets, Bonds, Commodities, Crypto
Research the full cross-asset picture:
- European markets (FTSE, DAX, CAC)
- Asian markets (Nikkei, Hang Seng, Shanghai)
- US Treasury yields (2Y, 10Y, 30Y)
- US Dollar index
- Oil, gold, Bitcoin
- VIX

## Agent 4: Tomorrow's Setup
Research what's coming tomorrow:
- Economic data releases scheduled
- Fed speakers scheduled
- Major earnings reports due (before and after market)
- Ongoing geopolitical situations that could escalate
- Futures indication if available
- What analysts and strategists are saying about what to expect

---

After all 4 agents return, compile everything into a single markdown report and save it to:

```
~/projects/trading-prep/reports/eod-report-YYYY-MM-DD.md
```

Use this exact structure:

# Market Report: [Date]

## The Damage (or The Recovery, depending on the day)
Table of major index closes with changes.

## What Caused It
Numbered list of converging catalysts, ranked by impact. Each with a bold heading and 2-3 lines of detail including specific numbers.

## Global Spillover
Table of cross-asset moves (gold, oil, yields, DXY, crypto, international indices).

## After-Hours Action
Any major earnings or moves after the close.

## Preparing for Tomorrow
### The Big Event (if there is one)
### Economic Calendar
### Earnings Calendar
### Futures as of Tonight
### Key Levels to Watch

## Notable Individual Movers
Table of biggest stock movers with move % and reason.

Keep it factual, data-dense, and concise. No filler. Every claim needs a number behind it.
