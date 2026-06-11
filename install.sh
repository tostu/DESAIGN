#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Branding Round Table — installer
# Installs the branding personas + orchestrator into Claude Code, Gemini CLI,
# and Google Antigravity. Idempotent. Supports global and per-project installs.
#
#   ./install.sh                 # install all three, globally (per-user)
#   ./install.sh --claude        # only Claude Code
#   ./install.sh --gemini --antigravity
#   ./install.sh --local ./myapp # install into a specific project folder
#   ./install.sh --uninstall     # remove everything it installed
#   ./install.sh --dry-run       # show what it would do
#   ./install.sh --help
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_PERSONAS="$SCRIPT_DIR/personas/branding"

# ---- defaults ----
TARGETS=()
SCOPE="global"          # global | local
LOCAL_DIR=""
ACTION="install"        # install | uninstall
DRY=0

PERSONAS=(vera-orchestrator paul-strategist lisa-naming maya-visual omar-insight \
          nina-critic theo-architect cleo-culture marcus-commercial felix-market)
MB="# >>> branding-round-table >>>"
ME="# <<< branding-round-table <<<"

# ---- colors ----
if [[ -t 1 ]]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; D=$'\033[2m'; R=$'\033[0m'; else B= G= Y= D= R=; fi
say()  { printf '%s%s%s\n' "$G" "$1" "$R"; }
warn() { printf '%s%s%s\n' "$Y" "$1" "$R"; }
step() { printf '  %s%s%s\n' "$D" "$1" "$R"; }
run()  { if [[ $DRY -eq 1 ]]; then printf '  %s[dry-run]%s %s\n' "$D" "$R" "$*"; else eval "$@"; fi; }

usage() {
  cat <<USAGE
${B}Branding Round Table installer${R}

Usage: ./install.sh [targets] [scope] [action]

Targets (default: all)
  --claude          Claude Code        -> ~/.claude/agents + ~/.claude/commands
  --gemini          Gemini CLI         -> ~/.gemini/agents + ~/.gemini/commands
  --antigravity     Google Antigravity -> ~/.gemini/AGENTS.md (global rule block)
  --all             all three (default)

Scope (default: --global)
  --global          install per-user, available in every project
  --local <dir>     install into one project folder (full self-contained copy)

Action
  --uninstall       remove what this installer added
  --dry-run         print actions without making changes
  -h, --help        this help
USAGE
}

# ---- parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude)              TARGETS+=(claude) ;;
    --gemini)              TARGETS+=(gemini) ;;
    --antigravity|--anti)  TARGETS+=(antigravity) ;;
    --all)                 TARGETS=(claude gemini antigravity) ;;
    --global)              SCOPE="global" ;;
    --local)               SCOPE="local"; LOCAL_DIR="${2:-}"; shift ;;
    --uninstall)           ACTION="uninstall" ;;
    --dry-run)             DRY=1 ;;
    -h|--help)             usage; exit 0 ;;
    *) echo "Unknown option: $1"; echo; usage; exit 1 ;;
  esac
  shift
done
[[ ${#TARGETS[@]} -eq 0 ]] && TARGETS=(claude gemini antigravity)

# ---- resolve destinations ----
if [[ "$SCOPE" == "local" ]]; then
  [[ -z "$LOCAL_DIR" ]] && { echo "--local needs a directory"; exit 1; }
  mkdir -p "$LOCAL_DIR"; LOCAL_DIR="$(cd "$LOCAL_DIR" && pwd)"
  CLAUDE_AGENTS="$LOCAL_DIR/.claude/agents"; CLAUDE_CMDS="$LOCAL_DIR/.claude/commands"
  GEMINI_AGENTS="$LOCAL_DIR/.gemini/agents"; GEMINI_CMDS="$LOCAL_DIR/.gemini/commands"
  AG_AGENTSMD="$LOCAL_DIR/AGENTS.md"
else
  CLAUDE_AGENTS="$HOME/.claude/agents"; CLAUDE_CMDS="$HOME/.claude/commands"
  GEMINI_AGENTS="$HOME/.gemini/agents"; GEMINI_CMDS="$HOME/.gemini/commands"
  AG_AGENTSMD="$HOME/.gemini/AGENTS.md"
fi

has() { local x; for x in "${TARGETS[@]}"; do [[ "$x" == "$1" ]] && return 0; done; return 1; }

copy_personas() {
  local dest="$1" strip_meta="${2:-0}"; run "mkdir -p '$dest'"
  local f base
  for f in "$SRC_PERSONAS"/*.md; do
    base="$(basename "$f" | sed -E 's/^[0-9]+-//')"
    if [[ $strip_meta -eq 1 ]]; then
      if [[ $DRY -eq 1 ]]; then step "would copy (strip meta) $base -> $dest"; continue; fi
      sed -E '/^(color|emoji|vibe):/d' "$f" > "$dest/$base"
    else
      run "cp '$f' '$dest/$base'"
    fi
  done
}

remove_personas() {
  local dest="$1" p
  for p in "${PERSONAS[@]}"; do run "rm -f '$dest/$p.md'"; done
}

# Remove our marker block from a file (portable, no sed -i quirks)
strip_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if grep -qF "$MB" "$file" 2>/dev/null; then
    run "awk -v b='$MB' -v e='$ME' '\$0==b{s=1} s==0{print} \$0==e{s=0}' '$file' > '$file.tmp' && mv '$file.tmp' '$file'"
  fi
}

# ============================ command bodies ============================
write_claude_cmd() {
  run "mkdir -p '$CLAUDE_CMDS'"
  if [[ $DRY -eq 1 ]]; then step "would write $CLAUDE_CMDS/brand-debate.md"; return; fi
  cat > "$CLAUDE_CMDS/brand-debate.md" <<'CMD'
---
description: Convene the branding round table — a critical, creative debate ending in a decision brief + scorecard.
argument-hint: <what you're branding> (e.g. "name a B2B fintech for freelancers")
---
Run a **branding round table** by adopting the `vera-orchestrator` sub-agent (the Creative
Director). Brief from the user: **$ARGUMENTS**

Rules: always include `nina-critic` and `omar-insight`; pull in the other specialists the
brief needs (`paul-strategist`, `lisa-naming`, `maya-visual`, `theo-architect`,
`cleo-culture`, `marcus-commercial`, `felix-market`). On naming rounds, always seat
`felix-market` — he runs the 6-test companyness check on every shortlist. No idea passes without a substantive objection. No
first-pass consensus. Every claim needs a branding rationale, not taste.

Run order: Intake → Divergence → Critique → Defense → Convergence + scorecard → The call.
Score finalists on Distinctiveness, Strategic fit, Memorability, Scalability, Ownability,
Resonance. End by showing the scorecard and Vera's call inline, and write the decision brief
(winner, the one reason it wins, what it trades away, dissent on record) to `./briefs/`.
CMD
  step "wrote $CLAUDE_CMDS/brand-debate.md"
}

write_claude_brief_cmd() {
  run "mkdir -p '$CLAUDE_CMDS'"
  if [[ $DRY -eq 1 ]]; then step "would write $CLAUDE_CMDS/brand-brief.md"; return; fi
  cat > "$CLAUDE_CMDS/brand-brief.md" <<'CMD'
---
description: Run the brand personality quiz — 8 chapters of deep questions to build a full Brand Brief before the debate.
argument-hint: <what you're branding> (e.g. "a B2B fintech for freelancers")
---
You are running the `/brand-brief` workflow. Read `.agents/workflows/brand-brief.md` in full
before doing anything else — it contains every chapter, every question, and the rules.

Project from the user: **$ARGUMENTS**

If no project is provided, open as Vera and ask for one.

⚠️ Check your execution environment. If the Task tool is available, spawn each chapter's
host persona as a real sub-agent. If not, run in Single-Agent Mode: voice each persona in
character under their name, with the same depth and rigour.

Run order:
1. Vera opens — introduce the 8 chapters, get consent to start.
2. Chapter 1 — Paul (The Spark): purpose, one word to own, founding story.
3. Chapter 2 — Omar (The People): audience truth, assumptions; Felix guest probe.
4. Chapter 3 — Paul + Cleo + Omar (The World): competition, category, distinctiveness.
5. Chapter 4 — Paul (The Soul): values, non-negotiables; silent 9-ideals check.
6. Chapter 5 — Lisa (The Voice): tone, forced choices, say-it-out-loud test.
7. Chapter 6 — Maya + Cleo (The Face): visual instincts, distinctive asset.
8. Chapter 7 — Nina (The Tension): shadow, pre-mortem, hostile reading. Do NOT rush.
9. Chapter 8 — Theo + Marcus (The Horizon): scale, architecture, commercial reality.
10. Synthesis — Omar distils signal/tension/opportunity; read back, invite correction.
11. Vera writes the brief using `templates/brand-brief-template.md`. Quote exact words.
12. Read back, revise once, lock. Save to `briefs/<YYYY-MM-DD>-<slug>-brief.md`.

One question at a time. "I don't know" = open question, not a gap. Do not propose names
or positioning — record instincts, save opinions for `/brand-debate`. Flag contradictions.
CMD
  step "wrote $CLAUDE_CMDS/brand-brief.md"
}

write_gemini_cmd() {
  run "mkdir -p '$GEMINI_CMDS'"
  if [[ $DRY -eq 1 ]]; then step "would write $GEMINI_CMDS/brand-debate.toml"; return; fi
  cat > "$GEMINI_CMDS/brand-debate.toml" <<'CMD'
description = "Convene the branding round table — a critical, creative debate ending in a decision brief + scorecard."
prompt = """
Run a branding round table led by @vera-orchestrator (the Creative Director).
Brief from the user: {{args}}

Always include @nina-critic and @omar-insight; delegate to the other specialists the brief
needs (@paul-strategist, @lisa-naming, @maya-visual, @theo-architect, @cleo-culture,
@marcus-commercial, @felix-market). On naming rounds, always seat @felix-market — he
runs the 6-test companyness check on every shortlist. No idea passes without a substantive objection. No first-pass consensus.
Every claim needs a branding rationale, not taste.

Run order: Intake -> Divergence -> Critique -> Defense -> Convergence + scorecard -> The call.
Score finalists on Distinctiveness, Strategic fit, Memorability, Scalability, Ownability,
Resonance. End by showing the scorecard and Vera's call, and write the decision brief
(winner, the one reason it wins, what it trades away, dissent on record) to ./briefs/.
"""
CMD
  step "wrote $GEMINI_CMDS/brand-debate.toml"
}

write_gemini_brief_cmd() {
  run "mkdir -p '$GEMINI_CMDS'"
  if [[ $DRY -eq 1 ]]; then step "would write $GEMINI_CMDS/brand-brief.toml"; return; fi
  cat > "$GEMINI_CMDS/brand-brief.toml" <<'CMD'
description = "Run the brand personality quiz — 8 chapters of deep questions to build a full Brand Brief before the debate."
prompt = """
Run the /brand-brief workflow. Read `.agents/workflows/brand-brief.md` in full first.

Project from the user: {{args}}

Voice each chapter's host persona in character. Chapter owners:
  1 The Spark      -> @paul-strategist
  2 The People     -> @omar-insight (+ @felix-market guest probe)
  3 The World      -> @paul-strategist + @cleo-culture + @omar-insight
  4 The Soul       -> @paul-strategist
  5 The Voice      -> @lisa-naming
  6 The Face       -> @maya-visual + @cleo-culture
  7 The Tension    -> @nina-critic  (do NOT rush this chapter)
  8 The Horizon    -> @theo-architect + @marcus-commercial
  Synthesis        -> @omar-insight distils, @vera-orchestrator writes the brief

One question at a time. "I don't know" = mark as open question.
Do not propose names or positioning — record instincts, save opinions for /brand-debate.
Flag contradictions between chapters explicitly.
Write the final brief to briefs/<YYYY-MM-DD>-<slug>-brief.md using templates/brand-brief-template.md.
"""
CMD
  step "wrote $GEMINI_CMDS/brand-brief.toml"
}

antigravity_block() {
  cat <<'RULE'
# Branding Round Table (auto-installed)
For any branding task — naming, positioning, identity, rebrand, tagline, tone of voice,
brand audit — do NOT answer with a single opinion. Run a critical, creative round table as
**Vera**, the Creative Director, voicing each persona in turn (single-agent mode).

Team: Vera (orchestrator) · Paul (strategy) · Lisa (naming/verbal) · Maya (visual) ·
Omar (insight — always) · Nina (critic — always) · Theo (architecture) · Cleo (culture) ·
Marcus (commercial/legal) · Felix (market proxy — seat on naming rounds). Built-in friction:
Paul(enduring) vs Cleo(now); Lisa(name) vs Felix(companyness) vs Marcus(trademark) vs
Theo(system); Maya(timeless) vs Nina(prove it).

House rules: (1) no idea passes without a substantive objection; no first-pass consensus.
(2) critique the idea, not the person. (3) every claim needs a branding rationale, not taste.
(4) proposers defend or concede out loud. (5) creativity is mandatory. (6) Vera breaks ties
and records the dissent.

Workflows:
  /brand-brief  — Run BEFORE /brand-debate when starting from scratch. Omar hosts an
                  8-chapter brand personality quiz (The Spark · The People · The World ·
                  The Soul · The Voice · The Face · The Tension · The Horizon). Each chapter
                  is led by the right specialist. Nina owns Chapter 7 (The Tension) and must
                  not be rushed. Omar distils the signal; Vera writes the brief to
                  briefs/<YYYY-MM-DD>-<slug>-brief.md using templates/brand-brief-template.md.
                  One question at a time. Do not propose names or positioning here.

  /brand-debate — Run AFTER /brand-brief (or with a supplied brief). Full round-table debate:
                  Intake → Divergence → Critique → Defense → Convergence + scorecard → The call.
                  Score finalists on Distinctiveness, Strategic fit, Memorability, Scalability,
                  Ownability, Resonance. Write the decision brief (winner, the one reason it
                  wins, what it trades away, dissent on record) to ./briefs/<YYYY-MM-DD>-<slug>.md.
RULE
}

upsert_antigravity() {
  run "mkdir -p '$(dirname "$AG_AGENTSMD")'"
  strip_block "$AG_AGENTSMD"
  if [[ $DRY -eq 1 ]]; then step "would add rule block to $AG_AGENTSMD"; return; fi
  { printf '\n%s\n' "$MB"; antigravity_block; printf '%s\n' "$ME"; } >> "$AG_AGENTSMD"
  step "added rule block to $AG_AGENTSMD"
}

# ============================ run ============================
printf '%sBranding Round Table%s  ·  %s  ·  scope=%s\n\n' "$B" "$R" "$ACTION" "$SCOPE"
[[ ! -d "$SRC_PERSONAS" ]] && { echo "Cannot find personas at $SRC_PERSONAS"; exit 1; }

if [[ "$ACTION" == "install" ]]; then
  if has claude;      then say "Claude Code";  copy_personas "$CLAUDE_AGENTS"; step "personas -> $CLAUDE_AGENTS"; write_claude_cmd; write_claude_brief_cmd; fi
  if has gemini;      then say "Gemini CLI";   copy_personas "$GEMINI_AGENTS" 1; step "personas -> $GEMINI_AGENTS"; write_gemini_cmd; write_gemini_brief_cmd; fi
  if has antigravity; then say "Antigravity";  upsert_antigravity; fi
  if [[ "$SCOPE" == "local" ]]; then
    run "mkdir -p '$LOCAL_DIR/briefs' '$LOCAL_DIR/templates'"
    run "cp -R '$SCRIPT_DIR/templates/.' '$LOCAL_DIR/templates/' 2>/dev/null || true"
    if has antigravity; then run "mkdir -p '$LOCAL_DIR/.agents/rules' '$LOCAL_DIR/.agents/workflows'"
      run "cp '$SCRIPT_DIR/.agents/rules/branding-agency.md' '$LOCAL_DIR/.agents/rules/' 2>/dev/null || true"
      run "cp '$SCRIPT_DIR/.agents/workflows/brand-debate.md' '$LOCAL_DIR/.agents/workflows/' 2>/dev/null || true"
      run "cp '$SCRIPT_DIR/.agents/workflows/brand-brief.md'  '$LOCAL_DIR/.agents/workflows/' 2>/dev/null || true"
    fi
  fi
  echo; say "Done."
  echo "${D}Try it:  Claude/Antigravity → /brand-brief <project>  then  /brand-debate <brief>   ·   Gemini → /agents reload, then /brand-brief or /brand-debate${R}"
else
  if has claude;      then say "Removing Claude Code";  remove_personas "$CLAUDE_AGENTS"; run "rm -f '$CLAUDE_CMDS/brand-debate.md' '$CLAUDE_CMDS/brand-brief.md'"; fi
  if has gemini;      then say "Removing Gemini CLI";   remove_personas "$GEMINI_AGENTS"; run "rm -f '$GEMINI_CMDS/brand-debate.toml' '$GEMINI_CMDS/brand-brief.toml'"; fi
  if has antigravity; then say "Removing Antigravity";  strip_block "$AG_AGENTSMD"; fi
  echo; say "Uninstalled."
fi
