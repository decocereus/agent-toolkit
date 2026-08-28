---
name: porto-deploy
description: Deploy, inspect, restart, configure, or verify Avail services through Porto over SSH. Use when a task mentions Porto, ssh porto, apps:deploy, apps:info, apps:redeploy, Porto logs/events/config/secrets, Avail HQ deployment, Nightshade sequencer/solver/orchestrator deployment, or canary/testnet/mainnet Porto rollout verification.
---

# Porto Deploy

## Required First Step

Before running any Porto command, read `references/porto-agent-deployment-runbook.md`.

Porto is accessed through SSH:

```bash
ssh porto "<porto-command>"
```

Do not assume a local `porto` binary exists.

## Operating Rules

- Start with evidence: `git status --short --branch`, target app name, current ref, and `ssh porto "apps:info <app>"`.
- Use full app triplets like `team/level/name`; avoid partial names unless Porto output proves them unambiguous.
- Use full commit SHAs for commit deploys. Short SHAs can fail with `couldn't find remote ref`.
- Verify the branch or commit is pushed to GitHub before deploying.
- Treat mainnet deploys as staged until the helm-values PR is merged. Do not say mainnet is live just because Porto opened a PR.
- After deploy or merge, verify expected SHA/image, pod health, logs, events, and any relevant HTTP health endpoint.
- Do not print private keys, SSM values, Clerk secrets, database URLs, `.env.local`, or other secret material.
- Do not mutate Porto config, secrets, resources, domains, lifecycle, or staged changes unless the user asked for that exact write.

## Nightshade Defaults

For Nightshade/ShieldTX deploys, verify the intended checkout before changing or deploying anything. If the user points to a sibling worktree or says "not this one", use that checkout exactly.

Known common target:

```text
nightshade/canary/orchestrator
```

Useful rollout skeleton:

```bash
git status --short --branch
git rev-parse HEAD
ssh porto "apps:list"
ssh porto "apps:info nightshade/canary/orchestrator"
ssh porto "apps:deploy nightshade/canary/orchestrator $(git rev-parse HEAD)"
```

Then verify with app info, logs/events, direct health checks, and config checks from the runbook.
