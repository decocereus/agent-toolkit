# Onboarding interview — vision, goals, use cases

Run this the first time the skill is used, or when no investor profile exists.
Goal: in ~10 minutes, learn enough to give advice that fits *this* person,
then save it so they never have to repeat it.

## How to run it

- **Five short rounds, not one wall of questions.** 3–5 questions per round.
  Use the AskUserQuestion tool for multiple-choice items where it is
  available (the investor can always type their own answer); ask open
  questions in plain text.
- **One sentence of "why I'm asking"** before each round, no more.
- **Accept "skip" or "not sure".** Record it as unknown and move on. Never
  stall the interview on one answer.
- **Reflect back after each round** in 1–2 lines ("So: 8-year horizon, house
  down-payment in 2029, comfortable with a 25% dip") so they can correct you.
- **Do not give stock opinions mid-interview.** If they ask, park it: "Noted —
  I'll answer that right after we finish."
- Voice-dictated answers are fine; tidy them up, don't make them retype.

---

## Round 1 — Who you are (context that changes the advice)

*Why: tax, risk capacity and time horizon all depend on this.*

1. Name, age range, and city. Are you an Indian tax resident?
2. How do you earn — salaried, business, freelance, student? Roughly how
   stable is that income?
3. **Emergency fund:** do you have 6+ months of expenses set aside outside
   equities? (Yes / Partly / No)
4. Any loans (home, car, education, personal, credit-card balances)? Any
   dependents relying on your income?
5. How much investing experience do you have?
   - New — haven't bought a stock yet
   - Some — a few trades, mostly via apps / tips
   - Regular — invest monthly, understand P/E, ROCE, STCG/LTCG
   - Experienced — read filings, have a process

**Flag immediately (before any stock talk) if:** no emergency fund, or
high-interest debt (credit card, personal loan). Paying that down usually beats
any equity return. Say so once, plainly, and let them decide.

## Round 2 — Your vision (why you're investing at all)

*Why: the goal decides the bucket, the horizon decides how much volatility
you can afford.*

1. In your own words: what do you want this money to do for you? (Freedom from
   a job, a house, a wedding, kids' education, beat FD returns, build long-term
   wealth, learn the market, something else.)
2. List any **specific goals with an amount and a year** — e.g. "₹25 lakh for a
   house down-payment by 2030". Which of these money must be ready on time, no
   matter what?
3. What does success look like **in 5 years**? A number, a lifestyle, a skill?
4. Do you have a view on markets/themes? (e.g. "India growth story", defence,
   EVs, renewables, financials, consumption, PSUs, global/US stocks.) Any
   sectors you want to **avoid** — for ethical reasons, or because your job
   already exposes you to them?
5. How involved do you want to be?
   - Set-and-forget: tell me once a month
   - Weekly check-in
   - Active: daily scans and trading ideas

**Rule that comes out of this round:** money needed for a dated goal within
~3 years should not be in direct small/mid-cap stocks. Say so if it is.

## Round 3 — Your money (what's in scope)

*Why: I need to know what I'm managing, and what I must leave alone.*

1. How much can you invest **each month**, and is there a lump sum to deploy
   now? Is the monthly amount fixed or variable?
2. Which brokers/apps hold your investments (Zerodha, Groww, INDmoney, Upstox,
   Angel, Kotak, others)? **Which of these do you want me to actively manage,
   and which should I leave out of scope?** (Out-of-scope accounts are never
   analysed unless you ask — but tell me roughly what's in them so I can warn
   about overlap.)
3. What do you already hold — stocks, mutual funds, ETFs, gold, FDs, PF/PPF,
   NPS, crypto? Rough values are fine.
4. Anything illiquid: ESOPs/RSUs (vesting schedule?), money in a friend's
   startup, real estate, a family business? (These count in risk maths, not in
   liquid net worth. Unvested ESOPs are contingent, not owned.)
5. Have you sold any stocks for a profit this financial year (April onward)?
   Roughly how much? (Needed to track the LTCG exemption and STCG.)

## Round 4 — Risk and behaviour (the honest part)

*Why: most retail losses come from behaviour, not stock selection. I'll watch
for your specific patterns.*

1. If your portfolio fell **25% in three months**, what would you actually do?
   (Sell / Hold and stop looking / Buy more / Honestly don't know.) And what
   ₹ loss would start costing you sleep?
2. Tell me about your **best and worst trade** so far — what you bought, why,
   and what you did when it moved. (Skip if new.)
3. Which of these sound like you? (pick any)
   - I buy after a stock has already run up a lot
   - I sell winners too early and hold losers too long
   - I re-buy stocks I've made money on, even at much higher prices
   - I act on tips / YouTube / Telegram / friends
   - I average down when a stock falls
   - I check prices many times a day
   - None / not sure yet
4. F&O, intraday, margin (MTF) or leverage: never / curious / already doing it?
   (Default in this skill is **never** — I'll flag it every time unless you
   tell me otherwise and accept the warning.)
5. Rules you already follow, or want me to hold you to? (e.g. "never more than
   20% in one stock", "no penny stocks", "only profitable companies".)

## Round 5 — How you want to use me

*Why: so the output fits your day, not mine.*

1. Which of these do you want? (pick any)
   - **Monthly deployment** — where to put this month's money
   - **Position reviews** — hold / add / sell, with exit levels
   - **News scan** on my holdings — only what changes the thesis
   - **Idea screening** — one-pager on a stock I'm curious about
   - **IPO analysis** — apply or skip
   - **Tax planning** — STCG/LTCG, harvesting, timing sales
   - **Learning mode** — explain concepts as we go
   - **Momentum / trend ideas** — stocks in strong uptrends
2. Your split between **core** (multi-year holds) and **tactical** (trades you'd
   exit within a year for a target)? E.g. 70/30, 100/0. Not sure is fine —
   I'll suggest one.
3. Direct stocks only, or mix with index funds/ETFs? Roughly how many stocks
   do you want to own (5? 15? doesn't matter)?
4. Format: short phone-screen answers, or detailed tables? English, Hindi or
   Hinglish? Any jargon you want me to avoid?
5. What data tools do you have connected in Claude (a broker connector like
   INDmoney/Zerodha, Screener, web search)? If none, I'll work from web search
   and screenshots/exports you share.

---

## After the interview — write the profile

1. Fill `assets/profile-template.md` from the answers. Use their words where
   possible. Mark unknowns as `unknown` — never guess.
2. Add a short **"What I'll hold you to"** section: 3–5 lines derived from
   Round 4 (their own stated weaknesses and rules), phrased as things to flag.
3. Add **"Suggested starting setup"** — your proposal, clearly labelled as a
   suggestion: core/tactical split, minimum position size (see
   `rules.md` §3 on cost drag), rough number of names, which workflows to run
   and how often. Give one line of reasoning each.
4. Show the profile to them and ask: "Anything wrong or missing?" Apply edits.
5. **Save it** (in this order of preference):
   - The local Obsidian vault is available → write `investing/investor-profile.md`
     there, with `README.md`, `decision-register.md` and `positions-and-levels.md`
     beside it, and link the folder from the vault `INDEX.md`. Add a short
     memory pointer to it if memory is on.
   - Memory is available → save the profile to memory (one file, e.g.
     `investor-profile`) — only after they confirm. Respect memory privacy
     rules: do not store account numbers, PAN, or anything they ask you not to.
   - In a Project with the Projects tool → write `investor-profile.md`.
   - Neither → give them the profile in a code block and say: "Paste this into
     a Project's instructions (or the start of a chat) so I start from it next
     time."
6. Then answer whatever they originally asked, using the profile.

## Refreshing

Offer a refresh when the profile is >6 months old, or on any life change.
Re-ask only the affected rounds, show the diff, save the new version, and keep
a one-line dated changelog at the bottom of the profile.
