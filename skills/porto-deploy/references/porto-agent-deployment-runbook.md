# Porto Agent Deployment Runbook

Use this runbook when a Codex agent needs to deploy Avail services through Porto from a branch, tag, or commit ref.

## SSH Access

Porto is accessed through SSH, not a local Porto binary.

Expected local SSH config:

```sshconfig
Host porto
  HostName porto.avail.tools
  User abheektripathy
  IdentityFile ~/.ssh/hq_ed25519
  IdentitiesOnly yes
```

Expected local key files:

```bash
~/.ssh/hq_ed25519
~/.ssh/hq_ed25519.pub
```

Do not print private key contents. To verify access:

```bash
ssh porto "help"
```

If Porto rejects the key and the user asks to rotate/update it, use the public key only:

```bash
ssh porto "keys:set $(cat ~/.ssh/hq_ed25519.pub)"
```

Only run `keys:set` when the user explicitly wants to replace the authorized Porto key. Some Porto docs mention admin-managed `keys:add <username> <pubkey>`, `keys:remove`, and `keys:list`; use the command exposed by `ssh porto "help"` on the live server.

## Porto Command Pattern

All Porto commands are executed as:

```bash
ssh porto "<porto-command>"
```

Examples:

```bash
ssh porto "apps:list"
ssh porto "apps:info infra/mainnet/hq"
ssh porto "logs infra/mainnet/hq"
```

Porto app names are triplets:

```text
team/service-level/name
```

Examples:

```text
infra/mainnet/hq
nightshade/testnet/sequencer
nightshade/testnet/solver
nightshade/canary/sequencer
nightshade/canary/solver
```

Partial names may work when unambiguous, but agents should prefer full triplets.

Most per-app commands accept multiple apps in one quoted argument:

```bash
ssh porto "apps:info 'nightshade/canary/oracle nightshade/canary/solver'"
```

Wildcards can target all apps at a team/level, but always quote them so the local shell does not expand `*`:

```bash
ssh porto "apps:info 'nightshade/canary/*'"
ssh porto "config:get 'nightshade/canary/*'"
```

Do not use wildcards for `mainnet`: Porto rejects wildcard writes that would touch mainnet apps. Mainnet apps should be named explicitly.

Public hostnames follow Porto's service level rules:

```text
mainnet: name.team.avail.tools
other levels: name-level.team.avail.tools
```

In-cluster DNS is:

```text
team-level-name.default.svc.cluster.local
```

Example:

```text
nightshade-testnet-sequencer.default.svc.cluster.local
```

## Deploy From Branch Or Commit

First make sure the target branch/commit is pushed to GitHub.

For a local branch:

```bash
git status --short --branch
git push -u origin <branch>
```

For a commit, use the full SHA. Short SHAs may fail with `couldn't find remote ref`.

```bash
git rev-parse HEAD
```

Deploy with:

```bash
ssh porto "apps:deploy <app> <branch-or-full-sha>"
```

HQ example:

```bash
ssh porto "apps:deploy infra/mainnet/hq 9c0165798828afff95bdc1ae95ae52786bade1e2"
```

Nightshade example:

```bash
ssh porto "apps:deploy nightshade/testnet/sequencer <branch-or-full-sha>"
```

Porto also supports git-push deployment through an app remote:

```bash
git remote add porto "$(ssh porto "apps:remote <app>")"
git push porto <branch>
```

For agents, prefer `apps:deploy <app> <full-sha>` when asked to deploy a specific commit. It is explicit and avoids pushing the wrong branch.

## Mainnet / Helm PR Flow

For `mainnet` apps, Porto usually does not apply directly. It builds and pushes the Docker image, then opens a `helm-values` PR.

Typical output:

```text
PR opened (mainnet — merge manually to deploy): https://github.com/availproject/helm-values/pull/NNNN
```

When this happens:

1. Send the PR URL to the user for review/merge.
2. Do not claim the deploy is live yet.
3. After the user says it is merged, verify with Porto.

The helm PR usually changes only:

```text
environment/ams3-sandbox/networks/porto/teams/<team>/<level>/apps/<app>/helmfile.yaml
environment/ams3-sandbox/networks/porto/teams/<team>/<level>/apps/<app>/porto-meta.yaml
environment/ams3-sandbox/networks/porto/teams/<team>/<level>/apps/<app>/values.yaml
```

Check PR status:

```bash
gh pr view <pr-number> --repo availproject/helm-values --json state,mergedAt,mergeCommit,statusCheckRollup,url
```

If checks pass but `reviewDecision` is `REVIEW_REQUIRED`, tell the user to merge the PR.

```bash
gh pr view <pr-number> --repo availproject/helm-values --json state,mergeable,reviewDecision,statusCheckRollup,url
```

On mainnet, all write operations require manual merge. This includes `apps:deploy`, `apps:redeploy`, `apps:destroy`, `git push` deploys, `staged:apply`, and write commands run with `--apply`.

## Verify Deploy

After the helm PR is merged:

```bash
ssh porto "apps:info <app>"
ssh porto "logs <app>"
ssh porto "events:list --app <name> --team <team> --limit 5"
```

HQ HTTP check:

```bash
curl -I -sS https://hq.infra.avail.tools/ | head
```

Expected healthy HQ signs:

```text
last_deployed_sha: <expected full SHA>
image_tag:        <expected short SHA>
POD ... Running 1/1 ... RESTARTS 0
HTTP/2 200
[db] migrations up to date
HQ server running on http://localhost:3001
```

If `apps:info` shows the expected image/ref but the pod age/name has not changed after the helm PR merge, wait briefly and recheck. If it still has not rolled, trigger a redeploy:

```bash
ssh porto "apps:redeploy <app>"
```

On mainnet this may open another helm PR. If it does, send that PR URL to the user and verify after merge.

If a staged PR is pending, `apps:info` may show a `pending_pr` URL. Use:

```bash
ssh porto "staged:list <app>"
```

If the PR is still open, ask the user to merge or close it before creating another staged PR.

## Common Porto Commands

Discovery:

```bash
ssh porto "help"
ssh porto "apps:list"
ssh porto "apps:info <app>"
ssh porto "apps:remote <app>"
ssh porto "apps:get-config <app>"
ssh porto "apps:get-github <app>"
```

Deploy and restart:

```bash
ssh porto "apps:deploy <app> <branch-or-full-sha>"
ssh porto "apps:rebuild <app>"
ssh porto "apps:redeploy <app>"
ssh porto "apps:enable <app>"
ssh porto "apps:disable <app>"
ssh porto "apps:set-service-level <app> devnet|testnet|canary|mainnet"
ssh porto "apps:get-service-level <app>"
```

Logs and runtime:

```bash
ssh porto "logs <app>"
ssh porto "logs <app> --tail"
ssh porto "events:list --app <name> --team <team> --limit 10"
ssh porto "metrics <app>"
ssh porto "run <app> -- <cmd> [args...]"
```

Note: `run` may be admin-only for some apps. If it returns `permission denied: admin only`, do not retry destructively; report the blocker.

Config:

```bash
ssh porto "config:get <app>"
ssh porto "config:set <app> KEY=value"
ssh porto "config:unset <app> KEY"
```

Most config/resource/domain/secret write commands stage by default. Add `--apply` to apply immediately:

```bash
ssh porto "config:set <app> KEY=value --apply"
```

Deploy commands (`apps:deploy`, `apps:rebuild`, and git-push deploys) incorporate staged changes into the deploy PR and clear the staged buffer after a successful deploy.

If `porto.toml` manages a section, Porto may warn about values set through CLI that are not present in `porto.toml`. Removing a key from `porto.toml` does not unset it; use the matching `config:unset`, `secret:ssm:unset`, or `secret:k8s:unset`.

SSM-backed secrets:

```bash
ssh porto "secret:ssm:get <app>"
ssh porto "secret:ssm:set <app> KEY=/ssm/path"
ssh porto "secret:ssm:unset <app> KEY"
```

Kubernetes secret refs:

```bash
ssh porto "secret:k8s:get <app>"
ssh porto "secret:k8s:set <app> KEY=namespace/secret/key"
ssh porto "secret:k8s:unset <app> KEY"
ssh porto "secret:k8s:write <app> KEY=value"
ssh porto "secret:k8s:delete <app> KEY"
```

Resources and service ports:

```bash
ssh porto "resources:get <app>"
ssh porto "resources:set <app> cpu_request=250m cpu_limit=1 memory_request=512Mi memory_limit=1Gi"
ssh porto "resources:unset <app> <key>"
ssh porto "apps:set-port <app> <port>"
ssh porto "apps:unset-port <app>"
```

Domains and extra services:

```bash
ssh porto "domains:list <app>"
ssh porto "domains:add <app> <hostname>"
ssh porto "domains:remove <app> <hostname>"
ssh porto "apps:list-services <app>"
ssh porto "apps:add-service <app> <svc-name> <port> --target-port <target-port>"
ssh porto "apps:remove-service <app> <svc-name>"
```

Volumes:

```bash
ssh porto "volumes:list <app>"
ssh porto "volumes:add <app> <mount-path> --size <size>"
ssh porto "volumes:remove <app> <mount-path>"
```

Cron:

```bash
ssh porto "cron:list <app>"
ssh porto "cron:add <app> --name <name> --schedule '<cron>' --command '<cmd>'"
ssh porto "cron:remove <app> <job-name>"
```

Staged changes:

```bash
ssh porto "staged:list <app>"
ssh porto "staged:apply <app>"
ssh porto "staged:clear <app>"
```

Mainnet staged applies generally open a PR requiring manual merge.

Alerts:

```bash
ssh porto "alerts:provision <app>"
ssh porto "alerts:list <app>"
ssh porto "alerts:set <app> cpu|memory|errors|panic <value>"
ssh porto "alerts:set <app> pod-health"
ssh porto "alerts:unset <app> <rule>"
ssh porto "alerts:set-channel <app> <channel>"
```

App lifecycle:

```bash
ssh porto "apps:create <team/level/name>"
ssh porto "apps:destroy <team/level/name>"
ssh porto "apps:set-config <app> <path>"
ssh porto "apps:get-config <app>"
ssh porto "apps:set-github <app> <org/repo>"
ssh porto "apps:get-github <app>"
ssh porto "apps:toml <app>"
ssh porto "apps:toml <app> --diff"
ssh porto "apps:toml <app> --pr"
```

Addons:

```bash
ssh porto "addon:info <addon>"
ssh porto "addon:create <team/level/name> <type>"
ssh porto "addon:ready <addon>"
ssh porto "addon:attach <addon> <app>"
ssh porto "addon:detach <addon> <app>"
ssh porto "addon:query <addon> '<SQL>'"
ssh porto "addon:destroy <addon>"
```

`addon:query` is read-only for Postgres addons and may be admin-only on `mainnet`/`canary`.

## HQ-Specific Quick Deploy

Use this when deploying HQ:

```bash
cd /Users/abheektripathy/Documents/code/avail/hq
git status --short --branch
git pull --ff-only origin main
FULL_SHA="$(git rev-parse HEAD)"
ssh porto "apps:deploy infra/mainnet/hq ${FULL_SHA}"
```

If Porto opens a helm PR, send it to the user:

```bash
gh pr view <pr-number> --repo availproject/helm-values --json url,state,mergeable,reviewDecision,statusCheckRollup
```

After merge:

```bash
ssh porto "apps:info infra/mainnet/hq"
ssh porto "logs infra/mainnet/hq"
curl -I -sS https://hq.infra.avail.tools/ | head
```

## Safety Rules For Agents

- Never print private keys, SSM values, Clerk secrets, database URLs, or `.env.local`.
- Use full commit SHAs for deploys unless deploying a named branch.
- Do not say a deploy is live when Porto only opened a helm PR.
- When blocked by `REVIEW_REQUIRED`, send the helm PR URL to the user.
- Verify the deployed SHA, pod health, HTTP status, and logs after merge.
- Do not use destructive git commands like `git reset --hard` unless explicitly requested.
- Do not mutate Porto secrets or config unless the user asked for that exact change.