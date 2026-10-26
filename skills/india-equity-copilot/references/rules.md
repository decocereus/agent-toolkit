# Rules — what governs every recommendation

Two kinds of rules live here:

- **Standards on Claude's own work** (§1, §2) — binding. They exist because a
  recommender that skips them produces confident, badly-sized, indefensible
  calls. The investor cannot waive these by asking; they are how Claude earns
  trust.
- **Defaults for the investor** (§3 onward) — evidence-based starting points.
  The investor may override any of them. Claude's job is then to state the
  breach and its size in one line, record the override with the reason, and do
  as asked. A rule bent quietly is a rule that does not exist.

Investing is judgement, not a formula. Numbers and checklists here are inputs to
judgement, never a substitute for it.

---

## 1. Data discipline (binding)

1. **No number from memory.** Price, P/E, market cap, results, analyst targets,
   tax rates — pull from a connector or search and cite with an as-of date.
   Cannot verify → say so.
2. **Pull before you contradict.** Never correct the investor about a price, a
   trade or a holding without pulling the data first.
3. **Source quality, in order:** NSE/BSE filings and investor presentations →
   company press releases → Screener/broker data → reputable news → aggregators,
   forums, YouTube, Telegram (signal only, never evidence).
4. **Label every claim:** fact (sourced, dated) / consensus (analyst view, with
   count, and the caveat that connector analyst sets are incomplete) /
   inference (your reasoning).
5. **Never infer trade history** (buy dates, prices, realised P&L) and present
   it as fact. Most broker connectors have no transaction history — ask for a
   capital-gains / tax P&L statement instead.
6. **Compare valuation to the Indian sector median**, never a global one. A
   global comparator can invert the conclusion entirely.
7. **Check the period.** A 15-month fiscal year, a demerger or a stock split
   breaks growth ratios and 52-week ranges. A "+800% gain" or "−60% off its
   high" on a demerged name is usually an accounting artifact — net it across
   the resulting entities.
8. **A technical reading is perishable.** Re-measure before acting on anything
   more than a day old. Measure weekly moving-average tests on **completed**
   weekly closes only — a reading inside an unfinished week is not a close.
9. **When two data sources disagree, recompute** (e.g. P/E = price ÷ TTM EPS)
   and name both sources. Do not quote either blind.

## 2. Recommendation-quality standard (binding)

These came from a real post-mortem: a stock was recommended at ~21% of a book,
in one order, into a commodity manufacturer, without anyone establishing the
price of the commodity. It fell 22%, and the exit had to be rewritten four
times because it was never derived from a thesis.

1. **No recommendation without unit economics.** For any manufacturer or
   commodity-exposed business, establish and state: price of what it sells,
   cost of its main input, industry capacity vs demand, and its position on the
   cost curve. Peer margins are the best corroboration (if the company's margin
   holds while peers' fall, it has a real edge; if all fall together, it is the
   cycle). Cannot establish it → "I cannot underwrite this." Do not propose it.
2. **The thesis is the exit.** Every invalidation leg must be a variable of the
   thesis — margin, volume, order intake, capacity delivery, funding, a
   regulatory outcome. A price level can be a *risk control*; it cannot be the
   invalidation. **No chart-based invalidation at all on a stock with under
   ~18 months of listed history** — the moving averages are not meaningful.
   An exit that needs rewriting more than once is evidence the thesis was never
   specified: say so instead of patching it.
3. **Sequential and year-on-year, always both.** Show the last four quarters
   sequentially (revenue, operating margin, PBT) next to YoY, and call it:
   accelerating or decelerating, noting seasonality. A big YoY number on a weak
   base can hide two quarters of sequential decline.
4. **Tranche 1 only.** Never propose a full position in one order. Write the
   trigger for tranche 2 (a price, a result, a confirmation).
5. **An entry-time red flag halves tranche 1.** Any medium-or-worse red flag
   (rising inventory/debtor days, high other income share of profit, promoter
   selling, leverage) or an unresolved analyst conflict → half size.
6. **Conviction is a number.** 0–100 scale: ≥75 high conviction; 60–74 a
   standard position, presented as a judgement call, never as "pick #1";
   <60 → recommend nothing. **"Deploy nothing this month" is a valid answer.**
   Unspent money carries forward; it is never forced into a name to use the
   month.
7. **Results check.** Do not recommend buying a few days before a scheduled
   quarterly result unless the investor explicitly wants the event risk.
8. **Bull and bear case, always,** with the bear case quantified where possible
   (e.g. "cheap at 11x is a bet that 35% margins hold; at 18% margins it is
   27x").

## 3. Defaults for the investor (evidence-based; overridable)

| # | Default | Why |
|---|---|---|
| D1 | **Write the exit before the entry**: entry (tranche #), target (with source), invalidation | Positions carried without one become bag-holds |
| D2 | **Stage entries, into weakness** — 2+ tranches, adding on pullbacks, not on gap-up days | In the original user's record, every staged position won big (+77%, +82%); every front-loaded one lost (−9% to −22%). Strongest evidence in the whole skill |
| D3 | **Tactical bucket: don't buy into a confirmed downtrend** (below a falling 40-week / 200-day average) | Both "bought a falling chart" trades lost |
| D4 | **Minimum position size** set so costs stay ≲0.4% round trip | Flat per-trade charges (DP charge on sell) dominate small trades. At ~₹3,600 average position, costs were 100% of one year's loss. Rough curve: ₹2k → ~1% drag, ₹7.5k → ~0.4%, ₹15k → ~0.3%. Verify against the investor's actual broker charge sheet |
| D5 | **Position caps as warnings**: ~25% of book in one name, ~40% in one theme | Standard prudence. Group themes by **measured** correlation of weekly returns (>~0.3 = same theme), plus two qualitative tests: same promoter group, or two businesses on one driver (e.g. broker + exchange both live on trading volumes) |
| D6 | **Default monthly order**: (1) add to a holding with a live, pre-written add level; (2) else a new name only if it beats the weakest current holding; (3) else reserve | Keeps the book from sprawling |
| D7 | **Portfolio-level stop**: book down >25% from peak → pause new buys, review every thesis | Individual stops don't protect against a correlated drawdown |
| D8 | **Benchmark quarterly** vs Nifty 500 (or the investor's chosen index), net of costs and tax. Two consecutive quarters of negative rolling 12-month alpha → honestly suggest indexing instead | Active only makes sense if it beats passive |
| D9 | **No leverage, F&O, MTF** unless the profile says otherwise | Not up for casual override |

## 4. Tax (raise unprompted)

**Confirm current rates by search before relying on them — they change in
Union Budgets.** As last verified (Oct 2026), for listed equity:
STCG (held ≤12 months) 20% under s.111A; LTCG (held >12 months) 12.5% under
s.112A, with the first ₹1.25 lakh of LTCG per FY exempt.

Before **any** sell, state:
1. Holding period per lot (needs buy dates — ask for the broker's tax P&L
   statement if the connector can't show them).
2. STCG vs LTCG and the tax in ₹.
3. **What waiting for the 12-month line is worth in ₹.** If a winner is within
   ~2 months of the line and the thesis is intact, recommend holding to cross
   it and say exactly what that saves.
4. Running realised gains this FY vs the ₹1.25 lakh LTCG exemption.
5. Loss harvesting: a realised short-term loss offsets STCG (and LTCG); state
   the ₹ value of the set-off — but tax is never the main reason to sell a
   broken thesis or hold a good one.

Perspective: for a small book, costs often leak more than tax. Don't let tax
optimisation override sizing or a broken thesis.

IPO listing-day sales are STCG. Momentum strategies with monthly rebalancing
make nearly every gain STCG — state that cost.

## 5. Behavioural patterns — name them directly, when forming

| Pattern | What it looks like | What to say |
|---|---|---|
| **Re-buying a past winner far above the old exit** | Sold at X, watched it run, wants back in at 1.4X near the high | "You're re-entering 40% above your own exit. Familiarity is reading as conviction." Set a re-entry trigger well below the current price and hold to it |
| **Chasing a run-up** | Wants to buy after a +10–15% day or near an all-time high | Name it; propose a pullback level for tranche 1 |
| **Averaging down on a broken thesis** | Adding because "it's cheaper now" while the thesis variable has failed | "The price fell because the thesis broke. Lower price ≠ better deal." |
| **Tactical becomes bag-hold** | A trade with no written exit, or an exit that keeps moving | "This is a core position you're calling tactical." |
| **Loosening an exit after it fires** | Rewriting the invalidation the day it triggers | Record it in the override log; if it happens twice, call it a pattern |
| **Selling just before LTCG** | Selling a winner weeks/months before 12 months | State the ₹ cost of not waiting |
| **Redeploying on the same day** | Selling a broken name and buying two new ones in one session | Make them separate decisions |
| **Relief selling at break-even** | A long loser returns to cost and they want out "just to be even" | "Break-even isn't a thesis. What does the plan say?" |
| **Tip-driven buying** | "Saw this on YouTube/Telegram" | Run the full one-pager before any money moves |
| **Investor's own patterns** | From the profile's "What I'll hold you to" | Watch for these specifically |

## 6. Technical inputs (confirmation, never a reason alone)

Report for every holding or candidate analysed:
- **Trend:** price vs 50-DMA, 200-DMA and the live 40-week average (completed
  weekly closes). Name the state: uptrend / on the average / downtrend.
- **RSI(14) on daily closes**, with direction vs 5 sessions ago.
  <30 oversold, 30–45 weak, 45–60 neutral, 60–70 strong, >70 overbought.
  RSI can sit below 30 for weeks in a downtrend — oversold is not a buy signal.
- **50/200-DMA cross:** golden or death, gap in %, and whether it crossed in
  the last 20 sessions (a fresh cross is the signal; an old one is just the
  state). Lags and whipsaws; buying on it is buying strength.
- Distance from 52-week high/low, and volume vs 20-day average.
- **Circuit limits** can make a stop level unreachable in one session — check
  the day's price band before claiming a level "will trigger".

## 7. Scored checklist (informs, never decides)

Score every candidate 0–2 on each, report every input:

| Input | 2 | 1 | 0 |
|---|---|---|---|
| Trend (vs 40-wk avg) | above, rising | within ±2% | below |
| Momentum (RSI + 50/200) | RSI 40–65 and golden cross | one of the two | RSI <30 falling or >75, and death cross |
| Valuation (vs Indian sector median) | ≥15% discount | ±15% | ≥15% premium without matching ROCE/growth |
| Fundamentals (red flags, ROCE, cash flow vs profit, pledge) | clean | 1–2 medium flags | any high flag |
| Consensus | ≥20% upside, ≥5 analysts | 10–20% or thin coverage | <10%, above mean, or SELL-heavy |
| Thesis & catalyst (investor's own words) | written + catalyst ≤2 qtrs | written, no near catalyst | none |
| **Unit economics (double weight, 0–4)** | 4: established, favourable | 2: partly / mixed | 0: not established → **veto** |

Reading (max 16): ≥12 strong · 8–11 judgement call · ≤7 needs a written reason
to buy. Translate to the 0–100 conviction number for §2.6. The investor's
written call decides.

## 8. Core vs tactical

| | Core | Tactical |
|---|---|---|
| Intent | multi-year; respects the LTCG line | exit inside a year on target or invalidation |
| Quality bar (guide) | ROCE >18%, ROE >15%, 3-yr sales and profit growth >15% (profit within ~5pp of sales — the margin-integrity test), D/E <1, pledge <5% | latest-quarter revenue >20% YoY, margins flat/up, catalyst within 2 quarters, pledge <5% |
| Trend rule | not required — a quality business bought cheap is below its averages by definition; check "de-rating, not deterioration" (revenue growing and margins steady over the last two quarters) | don't buy into a confirmed downtrend |
| Invalidation | fundamental thesis variable | thesis variable plus a risk-control price |

The investor names the bucket at entry. **If they call something core, hold
them to it** — no selling it on a 10% dip. If they call it tactical without an
exit, say it's a core position in disguise.

Why the thresholds: Indian listed cost of capital ~12–14% → ROCE 18% is a clear
spread. Nominal GDP ~10–11% → sales growth >15% means taking share. Pledge >5%
is the best-documented governance red flag in Indian small caps.

## 9. Momentum (optional sleeve, only if the profile wants it)

The core/tactical funnel deliberately stages into weakness, which means it
**cannot surface a momentum name** (stocks at new highs fail its tests by
design). If the investor wants momentum, run it as a **separate sleeve**, never
by loosening the tactical rules:

- Universe Nifty 500, rank by trend (vs 200-DMA) + 3–6 month return + nearness
  to 52-week high; top N equal-weight; exit only when a name drops out of the
  rank.
- Evidence: NSE's momentum indices rebalance semi-annually; third-party Indian
  backtests show a premium over the index but drawdowns near −70% (2008) with
  multi-year recovery. Monthly rebalancing makes most gains STCG and adds ~1%/yr
  friction.
- A basket needs enough capital for N names above the minimum position size —
  paper-trade it until then and log mechanical vs discretionary results.
- The sleeve never overrides a written invalidation on a real position.
