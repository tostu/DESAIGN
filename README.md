# Branding Round Table 🎙️

A small AI **design agency for branding** — nine personas with names, opinions, and a chip
on each shoulder. They don't agree to be polite: an orchestrator forces them to **argue
before they settle**, so the answer that survives is one the whole room has already tried to
break. Inspired by the agency-agents pattern, focused (for now) entirely on **branding**.

Runs in **Claude Code**, **Gemini CLI**, and **Google Antigravity** from the same files.

## The cast

| Persona | Role | Brings to the fight |
|---|---|---|
| 🎬 **Vera** | Creative Director / Orchestrator | Runs the debate, forces argument, writes the call |
| 🧭 **Paul** | Brand Strategist | Positioning, the "why", differentiation |
| 🔤 **Lisa** | Naming & Verbal Identity | Names, taglines, tone of voice |
| 🎨 **Maya** | Visual Identity Director | Logo, color, type, visual systems |
| 🔬 **Omar** | Insight & Research | Audience truth, evidence, semiotics |
| 🥊 **Nina** | Critic / Devil's Advocate | Red-teams everything, finds the failure mode |
| 🏛️ **Theo** | Brand Architect | Structure, sub-brands, scalability |
| 🌊 **Cleo** | Culture & Trends Scout | Fresh vs. dated, distinctiveness |
| 💼 **Marcus** | Commercial & Account | Budget, trademark/domain, stakeholder reality |

Built-in tensions make the debate real: Paul (enduring) vs. Cleo (now); Lisa (soulful name)
vs. Marcus (trademark) vs. Theo (system fit); Maya (timeless) vs. Cleo (trendy) vs. Nina
(prove it). Nina and Omar are in **every** session.

## How a session runs

`Intake → Divergence → Critique → Defense → Convergence + scorecard → The call → brief`

No idea passes without a substantive objection. No first-pass consensus. Every claim needs a
branding rationale, not taste. Vera makes the final call and records who still disagrees.
Each run writes a decision brief + scorecard to `briefs/`.

## Install

One script installs the personas into the right config location for each tool. From this folder:

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
| **Claude Code** | `~/.claude/agents/` + `~/.claude/commands/` | 9 sub-agents + `/brand-debate` |
| **Gemini CLI** | `~/.gemini/agents/` + `~/.gemini/commands/` | 9 sub-agents + `/brand-debate` |
| **Antigravity** | `~/.gemini/AGENTS.md` (a marked rule block) | round-table rule, single-agent mode |

The installer is idempotent (safe to re-run), never clobbers your existing `AGENTS.md` — it
only adds a clearly-marked block — and `--uninstall` removes exactly what it added. `--local`
copies the full agency (agents, commands, rules, templates, `briefs/`) into a project so every
relative path resolves. After a Gemini install, run `/agents reload` once to pick them up.

## Folder layout

```
DESAIGN/
├── AGENTS.md                       # cross-platform rules (Antigravity & AGENTS.md tools)
├── personas/branding/              # the 9 canonical persona files (source of truth)
├── .claude/
│   ├── agents/                     # the 9 personas as Claude Code sub-agents
│   └── commands/brand-debate.md    # /brand-debate slash command
├── .gemini/agents/                 # the 9 personas as Gemini CLI sub-agents
├── .agents/
│   ├── rules/branding-agency.md    # Antigravity workspace rule
│   └── workflows/brand-debate.md   # Antigravity /brand-debate workflow
├── templates/                      # decision-brief + scorecard templates
└── briefs/                         # session outputs land here
```

## Run it in Claude Code

The personas are already in `.claude/agents/` and the command in `.claude/commands/`.
From this folder:

```
/brand-debate name a B2B fintech for freelance designers
```

Or just describe the branding task — Claude will pull in Vera and the team. Vera spawns each
specialist as a real sub-agent so they argue in separate contexts, then writes the brief.
Tip: you can also call one specialist directly, e.g. *"have Nina red-team this tagline."*

## Run it in Gemini CLI

The personas are in `.gemini/agents/` (same format: markdown + YAML frontmatter). From this
folder:

```
/agents reload          # pick up the new agents
@vera-orchestrator run a brand debate to name a B2B fintech for freelance designers
```

Vera delegates to the specialist sub-agents via `@paul-strategist`, `@nina-critic`, etc.
You can also invoke any specialist directly with `@<name>`.

## Run it in Google Antigravity

Antigravity reads `AGENTS.md` and `.agents/rules/`. Open this folder as your workspace, then
either run the workflow or just ask:

```
/brand-debate name a B2B fintech for freelance designers
```

Antigravity runs in **single-agent mode**: one agent acts as Vera and voices each persona in
turn, following the same protocol and writing the same brief. (No per-persona sub-agents, but
the debate, critique, and scorecard are identical.)

## Customising

- Edit the canonical files in `personas/branding/`, then re-sync the copies:
  `for f in personas/branding/*.md; do b=$(basename "$f" | sed -E 's/^[0-9]+-//'); cp "$f" .claude/agents/$b; cp "$f" .gemini/agents/$b; done`
- Add a persona by copying a file's shape (frontmatter `name` + `description`, then the body
  becomes the system prompt) and adding them to Vera's roster table.
- Tune the scorecard criteria in `personas/branding/00-vera-orchestrator.md` and
  `templates/scorecard-template.md` to your category.

## Next departments

This is the branding pod. The same pattern extends to naming sprints, packaging, campaign
ideation, or a full agency (strategy, design, copy, web) — each as its own `personas/<dept>/`
folder with its own orchestrator.
