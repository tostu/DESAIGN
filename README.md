# Branding Round Table 🎙️

A small AI **design agency for branding** — eleven personas with names, opinions, and a chip
on each shoulder. They don't agree to be polite: an orchestrator forces them to **argue
across multiple rounds** before anything settles, so the name that survives is one the whole
room has already tried to break. Runs in **Claude Code**, **Gemini CLI**, and **Google
Antigravity** from the same files.

## The cast

| Persona | Role | Brings to the fight |
|---|---|---|
| 🎬 **Vera** | Creative Director / Orchestrator | Runs the debate, forces argument, writes the call |
| 🧭 **Paul** | Brand Strategist | Positioning, the "why", differentiation |
| 🔤 **Lisa** | Naming & Verbal Identity | Names, taglines, tone of voice |
| 🔭 **Sol** | Linguistic Explorer | Oxymorons, thesaurus chains, distant-domain compounds — the names nobody else finds |
| 🎨 **Maya** | Visual Identity Director | Logo, color, type, visual systems |
| 🔬 **Omar** | Insight & Research | Audience truth, evidence, semiotics |
| 🥊 **Nina** | Critic / Devil's Advocate | Red-teams everything, finds the failure mode |
| 🏛️ **Theo** | Brand Architect | Structure, sub-brands, scalability |
| 🌊 **Cleo** | Culture & Trends Scout | Fresh vs. dated, distinctiveness |
| 💼 **Marcus** | Commercial & Account | Budget, domain acquisition, stakeholder reality |
| 📊 **Felix** | Market Proxy | 6-test companyness check on every shortlist |
| 🚫 **Rex** | Availability Enforcer | Trademark / domain / handle clearance — RED cards are non-negotiable kills |

Built-in tensions make the debate real: Paul (enduring) vs. Cleo (now); Lisa (orthodox name)
vs. Sol (structural tension) vs. Felix (companyness) vs. Marcus (trademark) vs. Theo (system
fit); Maya (timeless) vs. Nina (prove it); Rex vs. everyone who falls in love before clearing.
**Omar, Nina, and Sol are in every session. Rex runs after every name-generation phase.**

## Two commands

### `/brand-brief` — start here
An 8-chapter brand personality quiz run by the right specialist per chapter. Surfaces purpose,
audience, values, voice, visual instincts, tensions, and commercial reality before a single
name is proposed. Nina owns Chapter 7 (The Tension) and is not rushed. Omar distils the
signal; Vera writes the brief to `briefs/`.

### `/brand-debate` — the naming fight
The full round-table debate. Supply the brief (or run `/brand-brief` first).

## How a debate runs

```
Intake → Divergence A → Rex Clearance A → Critique → Divergence B → Rex Clearance B
→ Hybridization → Rex Clearance C → Defense → Convergence → Persona Jury → Threshold gate
→ The call → brief
```

**Multiple divergence waves.** Each specialist (including Sol) pitches three options in Round 1
— safe, bold, wildcard. After critique exposes gaps, everyone proposes fresh ideas they
couldn't have pitched before seeing the field (Divergence B). Then a hybridization round
forces cross-pollination across rounds and personas.

**Rex clears names after every generation phase.** 🔴 RED = removed immediately, no appeal.
🟡 YELLOW = on hold for Marcus to assess commercial viability. Only GREEN and YELLOW-resolved
names advance.

**Persona jury with a threshold gate.** After convergence, every creative specialist scores
each of the 3 finalists 1–5 independently (blind voting). A name needs a jury average ≥ 3.5
and no single veto (score of 1) to be eligible to win.

**If no finalist clears the threshold, the debate doesn't end — it restarts.** The gap
analysis records which criteria and which personas consistently scored low; a targeted
Divergence C addresses exactly that gap. No fixed limit on restarts. A forced winner nobody
believes in is worse than going again.

No idea passes without a substantive objection. No first-pass consensus. Every claim needs a
branding rationale, not taste. Each run writes a decision brief + scorecard to `briefs/`.

## Install

```bash
./install.sh                 # all three tools, globally (available in every project)
./install.sh --claude        # just Claude Code
./install.sh --gemini --antigravity
./install.sh --local ./myapp # drop a self-contained copy into one project
./install.sh --uninstall     # remove everything it added
./install.sh --dry-run       # preview without changing anything
```

Where things land:

| Tool | Global install | What you get |
|---|---|---|
| **Claude Code** | `~/.claude/agents/` + `~/.claude/commands/` | 11 sub-agents + `/brand-debate` + `/brand-brief` |
| **Gemini CLI** | `~/.gemini/agents/` + `~/.gemini/commands/` | 11 sub-agents + `/brand-debate` + `/brand-brief` |
| **Antigravity** | `~/.gemini/AGENTS.md` (a marked rule block) | round-table rule, single-agent mode |

The installer is idempotent (safe to re-run). Commands are copied directly from the source
files in this repo — editing `.claude/commands/brand-debate.md` and re-running `install.sh`
is all it takes to deploy changes. `--uninstall` removes exactly what it added. `--local`
copies the full agency (agents, commands, rules, templates, `briefs/`) into a project so
every relative path resolves. After a Gemini install, run `/agents reload` once.

## Folder layout

```
DESAIGN/
├── AGENTS.md                           # cross-platform rules (Antigravity & AGENTS.md tools)
├── personas/branding/                  # 11 canonical persona files (source of truth)
├── .claude/
│   ├── agents/                         # 11 personas as Claude Code sub-agents
│   └── commands/
│       ├── brand-debate.md             # /brand-debate slash command
│       └── brand-brief.md              # /brand-brief slash command
├── .gemini/
│   ├── agents/                         # 11 personas as Gemini CLI sub-agents
│   └── commands/
│       ├── brand-debate.toml
│       └── brand-brief.toml
├── .agents/
│   ├── rules/branding-agency.md        # Antigravity workspace rule
│   └── workflows/
│       ├── brand-debate.md             # Antigravity /brand-debate workflow
│       └── brand-brief.md              # Antigravity /brand-brief workflow
├── templates/
│   ├── brand-brief-template.md
│   ├── scorecard-template.md           # includes Rex clearance table + persona jury
│   └── decision-brief-template.md
└── briefs/                             # session outputs land here
```

## Run it in Claude Code

```
/brand-brief name a B2B fintech for freelance designers
/brand-debate name a B2B fintech for freelance designers
```

Run via **`/brand-debate`** (not by calling `@vera` as a sub-agent). The command runs Vera in
the **main thread**, which is the only place that reliably spawns sub-agents — she launches
each specialist with the Task tool and shuttles arguments between rounds, because sub-agents
can't talk to each other directly. You can also invoke any specialist directly,
e.g. *"have Nina red-team this tagline"* or *"have Sol push further on these names."*

> **Vera isn't spawning sub-agents / she's role-playing everyone herself?**
> That happens when she's invoked *as* a sub-agent. Fix: use `/brand-debate` so she runs in
> the main thread. If you'd rather she voices everyone inline (faster, no separate contexts),
> tell her "single-agent mode" — same protocol, different mechanism.

## Run it in Gemini CLI

```
/agents reload
@vera-orchestrator run a brand debate to name a B2B fintech for freelance designers
```

## Run it in Google Antigravity

```
/brand-debate name a B2B fintech for freelance designers
```

Single-agent mode: Vera voices each persona in turn, following the same protocol and writing
the same brief. The debate, critique, Rex clearance, jury vote, and threshold gate all apply.

## Customising

Edit the canonical files in `personas/branding/`, then re-run `install.sh` to deploy. The
installer copies directly from the source — no manual sync needed. To add a persona: copy any
persona file's shape (YAML frontmatter with `name`, `description`, `color`, `emoji`, `vibe`,
then the body becomes the system prompt), add them to the `PERSONAS` array in `install.sh`,
and add them to Vera's specialist table in `personas/branding/00-vera-orchestrator.md`. To
tune scoring, edit `templates/scorecard-template.md` and the scorecard rubric in
`00-vera-orchestrator.md`.

## Next departments

This is the branding pod. The same pattern extends to naming sprints, packaging, campaign
ideation, or a full agency (strategy, design, copy, web) — each as its own `personas/<dept>/`
folder with its own orchestrator.
