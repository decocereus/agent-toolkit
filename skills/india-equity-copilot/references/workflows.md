# Workflows

Every workflow starts the same way: **profile loaded → holdings pulled (from
the in-scope broker connector, or ask for a screenshot/export) → rules.md
applied.** Output follows the profile's format preference.

---

## §1 Monthly deployment — "where does this month's money go?"

1. **Pull holdings and cash.** Book value, each position's share of book, P&L,
   bucket (core/tactical), and any live add levels already written.
2. **Market regime (context, not a gate):** Nifty 500 vs its 12-month average
   and distance from its 12-month peak. Risk-off → favour core quality at a
   discount, shrink tactical, keep more reserve.
3. **Check open decisions** (decision register, if any) and upcoming results
   dates for holdings and candidates — don't buy days before a result.
4. **Apply the default order** (rules.md D6): live add levels first → new name
   only if it beats the weakest holding → otherwise reserve.
5. **Size against the growing book, not the monthly cheque.** Concentrate into
   2–3 ideas a month, not ten. Every proposed buy is tranche 1 with a written
   tranche-2 trigger.
6. **Output — one table, then the reasoning:**

| Use of money | ₹ | Bucket | Why | Conviction |
|---|---|---|---|---|
| Add X, tranche 2 | | core | add level hit | 78 |
| New: Y, tranche 1 | | tactical | … | 66 (judgement call) |
| Reserve | | — | nothing else clears 60 | — |

Then for each buy: the three-line entry note (entry / target / invalidation),
bull vs bear, and any behavioural flag. **If nothing clears 60, the answer is
"deploy nothing; reserve carries forward"** — say it plainly.

## §2 Position review — "hold, add, or sell X?"

Answer first (HOLD / ADD at ₹__ / TRIM / EXIT), then:

1. **Thesis, in one sentence.** If none was ever written, say so — that is the
   first finding. Ask the investor for theirs.
2. **Is the thesis intact?** Test each invalidation leg against the latest
   data (filings first). Report which legs are clear, which tripped, which
   were never measured.
3. **Numbers:** price vs cost, share of book, trend/RSI/50-200 state, last four
   quarters sequential + YoY, valuation vs Indian sector median, red flags,
   consensus (count, upside, coverage caveat).
4. **Exit levels:** trim and target (with source), invalidation (thesis
   variables).
5. **Tax:** holding period per lot, STCG/LTCG, ₹ value of waiting for 12
   months, realised gains vs the exemption.
6. **Behavioural check:** anchoring on cost? relief selling at break-even?
   averaging down on a broken thesis? loosening an exit that just fired?
7. **Bull vs bear, side by side.**

If an exit fired and the investor wants to hold anyway: record it in the
override log as "invalidation loosened after firing", with their reason.

## §3 Holdings news scan — daily or weekly

Purpose: what **changes a thesis**, not daily price noise.

**Phone-screen summary first (~150 words):** verdict (any action needed?);
actionables, one line each; decisions due within 7 days; book total and day %;
any holding that moved >3% with the reason if known.

Then the detail (in a dated doc if in a Project):
- Each holding vs its levels (distance to trim / target / invalidation).
- Material news per holding: results, orders, regulatory actions (e.g. FDA
  observations for pharma), management changes, pledges, block deals,
  promoter selling, rating changes. Classify: thesis-supporting / neutral /
  thesis-threatening.
- Watchlist triggers newly met (never re-flag an item that was already flagged
  without new information).
- Behavioural flags (e.g. a past winner spiking on heavy volume).
- Tax items within 30 days of a 12-month line.
- Data and tool state: what failed, what's unverified.

An item flagged on a previous day with no new information is **not** an
actionable.

## §4 Idea one-pager — "what do you think of X?"

Verdict and conviction number first, then:

| Section | Content |
|---|---|
| **Business** | What it sells, to whom, how it makes money, in 3 lines |
| **Unit economics** | Output price, input cost, capacity vs demand, cost-curve position, peer margins. Not established → stop here: "I cannot underwrite this yet" |
| **Why now** | The catalyst within ~2 quarters |
| **What the market is missing** | The variant view — if there is none, say so |
| **Numbers** | 4 quarters sequential + YoY; ROCE/ROE; debt; cash flow vs profit; other income share of profit; promoter holding trend and pledge; valuation vs Indian sector median |
| **Technical state** | Trend, RSI, 50/200, distance from high/low |
| **Consensus** | Count, mean target, upside, known missing brokers |
| **What kills it** | The 2–3 thesis variables that would make you exit |
| **What I'd pay** | Entry band for tranche 1; tranche-2 trigger; target with source |
| **Checklist score** | rules.md §7, every input shown |
| **Bull vs bear** | Side by side |
| **Concentration** | Correlation / overlap with existing holdings and out-of-scope accounts |
| **Behavioural flag** | Is this a past winner? a tip? a chase? |

## §5 IPO — apply or skip

Default is **skip** unless the case is clear. Pull from the RHP/exchange
filings first; aggregators and grey-market premium (GMP) are unofficial and
unreliable — label them so.

1. **Fresh issue vs OFS** split; what the fresh money funds (growth capex vs
   debt repayment vs nothing).
2. **Who is selling**: promoter / PE exit share; post-issue promoter holding;
   lock-in schedule.
3. **Valuation vs listed peers** (P/E, EV/EBITDA, P/S) on **Indian** peers.
4. **Financial quality**: growth, margins, cash flow vs profit, related-party
   transactions, contingent liabilities.
5. **Anchor book quality**: long-only mutual funds/insurers vs short-term
   funds.
6. **Subscription data** by category, once available.
7. **Category and eligibility** (retail, shareholder quota, employee quota).
8. **Listing-day plan written before allotment**: e.g. gain ≥X% → sell half,
   hold rest above issue price; flat/negative → exit. Any sale within 12
   months is STCG — state the ₹.
9. **The honest case for skipping.**

Keep an `ipo-tracker` record: applied, lots, allotted or not, listing outcome.

## §6 Post-mortem — when a position goes badly

Purpose: separate a bad outcome from a bad process. Write it plainly, no
self-flagellation and no defence.

1. **Reconstruct what was known at entry** — from the record, not memory:
   size and share of book, number of orders, structure, red flags known,
   analyst conflicts, the exit as written.
2. **Score the process against rules.md §2 and §3**: unit economics done? exit
   built from thesis? staged? sequential trend read? red flags respected?
3. **Do the work that was skipped** (often the industry/unit-economics work).
4. **Verdict on the business today** — hold, exit, or "can't underwrite" —
   with a thesis-derived exit, labelled as a new version if the exit changed.
5. **Offer the honest alternative** (e.g. "selling to realise the loss is a
   rational response if you no longer trust the thesis; here is the tax
   set-off").
6. **One process change** that would have prevented it. Add it to the
   decision register.

## Scheduled runs (optional)

If the investor wants automatic daily/weekly scans and scheduling tools exist
in the session, offer to set them up as scheduled tasks. Each run must start
fresh: load the profile, pull holdings, follow §3, write a dated doc, and send
only the phone-screen summary.
