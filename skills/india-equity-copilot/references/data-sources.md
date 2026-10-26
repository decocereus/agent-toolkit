# Data sources — how to get numbers, and the known traps

Use whatever the session has. Check what is connected before saying something
can't be done; if a tool fails, retry once, then say what failed and carry on
with what works. **A doc or note claiming a tool "doesn't work" gets re-tested
once, not inherited.**

## Broker connectors (holdings, prices)

General rules for any broker connector (INDmoney, Zerodha Kite, Groww, Upstox…):

- **Pull holdings at the start of every portfolio conversation.** Filter to
  the accounts the profile marks in scope.
- **Sanity-check every row.** Aggregator connectors (e.g. INDmoney, which pulls
  in holdings from other brokers) can mislabel the broker on a row or blend
  units from two accounts into one. If a quantity looks wrong vs what the
  investor told you, ask, then record the correct figure in the profile as a
  "known data correction" and apply it every time.
- Rows imported from another broker may show **invested = current value** (no
  real cost basis). Never quote P&L on those rows.
- **Most connectors have no transaction history** — no buy dates, no realised
  trades. For holding periods and realised gains, ask for the broker's tax P&L /
  capital-gains statement. Never infer.
- **Read-only.** Claude cannot place orders, GTTs or watchlist changes. The
  investor does those in their app. Never claim an order or GTT exists or
  filled — most connectors can't see GTTs.
- 52-week high/low fields can lag one session on a fresh extreme; confirm from
  daily candles.
- Exclude stale quotes (check the price-updated timestamp) and broken analyst
  fields (e.g. target 0 / upside −100% is unusable, not bearish).
- Connector analyst consensus is **incomplete** — brokers are missing. Never
  restate it as "the market's view".

INDmoney specifics, if used: resolve every name with `lookup_ind_keys` first;
`networth_holdings` (asset_type IND_STOCK) for rows; `get_indian_stocks_details`
for LTP and analyst targets; `get_indian_stocks_ohlc` for candles (1day for
positional, 1week/1month for long-term); `get_indian_stocks_movers` for
market-wide discovery.

## Fundamentals

- **Screener connector** (if connected): quarterly results, financials, red
  flags, peer comparison, relative valuation, shareholding, announcements,
  screens. Notes from use:
  - Red-flag checks use year-end figures; compute half-year trends yourself
    from filings.
  - Don't sort or gate screens on PEG (historical-growth based, absurd values)
    or sort by ROCE (surfaces data artifacts).
  - Read the `partial` / coverage fields on screens — a partial scan is not a
    ranking.
  - Some company symbols differ from the NSE ticker; search first.
  - If endpoints disagree, recompute from price ÷ TTM EPS.
  - Self-hosted servers may sleep and fail the first call — retry once.
- **Filings:** NSE/BSE announcements, results PDFs, investor presentations,
  annual reports. Primary source; prefer for anything a decision rests on.
- **Web search** for news, industry data (capacity, prices), and anything not
  in a connector. Cite with dates. Vendor/aggregator figures are "indicative".

## Index and macro

- Regime: Nifty 500 vs its 12-month average and peak.
- Benchmarks: Nifty 500 or the investor's chosen index, total return where
  possible.

## When nothing is connected

Work from web search plus what the investor shares (broker screenshots, CSV
exports, tax P&L statements). Say plainly which numbers are verified and which
came from the investor. Suggest connecting their broker if a connector exists.
