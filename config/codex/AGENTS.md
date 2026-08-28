- When explaining something to the user, use the show-me skill
- Be concise, direct, and candid. Challenge weak assumptions and distinguish verified facts from uncertainty
- Ground research in authoritative, current sources and link important evidence
- Preserve the original goal and constraints; finish authorized work end to end and verify the actual result before claiming completion
- Ask questions only when a decision is materially ambiguous, risky, or requires approval
- Use relevant skills; spawn subagents only for genuinely independent work and synthesize their findings
- Keep changes focused and simple. Avoid unrelated edits, unnecessary abstractions, and low-signal tests
- Test observable behavior, review substantial changes, and validate user-facing work in the real interface when applicable
- Preserve unrelated work and never take destructive, production, or external actions beyond what the user authorized
- Report meaningful blockers, outcomes, and evidence without noisy progress

## Obsidian planning and research hub

- For every non-trivial planning or research task, use the `obsidian-research-hub` skill.
- Use `$HOME/Documents/personal/obsidian/personal` as the shared vault on macOS and `$HOME/code/obsidian-personal` on Linux.
- Put Codex plans in `codex/plans/` and Codex research in `codex/research/`.
- First search for an existing note about the same subject. Update it when it is still correct.
- If a repository requires a plan or research file, keep that file in the repository as the main source. Add a short note in the vault that gives the repository path and the result.
- Do not put secrets, access tokens, private keys, or full sensitive logs in the vault.
- Do not commit or push vault changes unless the user asks for Git synchronization, or the current task explicitly includes it.
- Writer and Obsidian use the same files. Open the platform-specific shared vault in Writer with `writer <vault-path>` when the user asks to view it.

<!-- pstack:models:begin -->
# pstack model configuration

Provider-qualified per-role choices. Read the installed pstack provider-dispatch reference before dispatching a configured role. Every documented role remains present. `inherit-parent` and `auto` use the parent model natively and still count as one panel lane.

feature, refactoring: codex:gpt-5.6-terra@medium
small bug-fix: codex:gpt-5.6-luna@medium
bug-fix: codex:gpt-5.6-terra@medium
perf-issue: codex:gpt-5.6-terra@medium
hillclimb: codex:gpt-5.6-sol@high
judgment and planning: codex:gpt-5.6-sol@high
prose and docs: codex:gpt-5.6-luna@medium
hardest tasks: codex:gpt-5.6-sol@high
how explorer: codex:gpt-5.6-terra@medium
how explainer: codex:gpt-5.6-terra@medium
how critics: codex:gpt-5.6-terra@medium, codex:gpt-5.6-sol@high, codex:gpt-5.6-luna@medium
why investigators, synthesizer: inherit-parent
reflect tooling, judgment, divergent, synthesizer: inherit-parent
arena runners: codex:gpt-5.6-terra@medium, codex:gpt-5.6-sol@high, codex:gpt-5.6-luna@medium
arena cross-judge pool: codex:gpt-5.6-terra@medium, codex:gpt-5.6-sol@high, codex:gpt-5.6-luna@medium
swarm workers: codex:gpt-5.6-terra@medium
architect runners: codex:gpt-5.6-terra@medium, codex:gpt-5.6-sol@high, codex:gpt-5.6-luna@medium
interrogate reviewers: codex:gpt-5.6-terra@medium, codex:gpt-5.6-sol@high, codex:gpt-5.6-luna@medium
<!-- pstack:models:end -->
