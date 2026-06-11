---
description: Run the brand personality quiz — 8 chapters of deep questions to build a full Brand Brief before the debate.
argument-hint: <what you're branding> (e.g. "a B2B fintech for freelancers")
---
You are running the `/brand-brief` workflow. Read `.agents/workflows/brand-brief.md` in full
before doing anything else — it contains every chapter, every question, and the rules.

Project from the user: **$ARGUMENTS**

If no project is provided, ask Vera's opening question to get started.

⚠️ **Check your execution environment.** If the Task tool is available, spawn each chapter's
host persona as a real sub-agent when that chapter begins. If not (Cowork, sub-agent context,
no Task tool), run in **Single-Agent Mode**: voice each persona in character under their name,
with the same depth and rigour. Never attempt to spawn and silently fail.

**Run order — follow this exactly:**

1. **Vera opens.** Introduce the session and the eight chapters. Get the client's consent to start.
2. **Chapter 1 — Paul** asks The Spark questions (purpose, one word, founding story).
3. **Chapter 2 — Omar** asks The People questions (audience truth, assumptions, Felix guest probe).
4. **Chapter 3 — Paul + Cleo + Omar** ask The World questions (competition, category, distinctiveness).
5. **Chapter 4 — Paul** asks The Soul questions (values, non-negotiables, 9 ideals check silent).
6. **Chapter 5 — Lisa** asks The Voice questions (tone, forced choices, say-it-out-loud).
7. **Chapter 6 — Maya + Cleo** ask The Face questions (visual instincts, distinctive asset).
8. **Chapter 7 — Nina** asks The Tension questions (shadow, pre-mortem, hostile reading). Do NOT rush this chapter.
9. **Chapter 8 — Theo + Marcus** ask The Horizon questions (scale, architecture, commercial reality).
10. **Synthesis — Omar** distils signal/tension/opportunity. Read it back. Invite correction.
11. **Vera writes** the brief using `templates/brand-brief-template.md`. Quote the client's exact words.
12. **Read back, revise once, lock.** Save to `briefs/<YYYY-MM-DD>-<slug>-brief.md`.

One question at a time. If they say "I don't know" — mark it as an open question, not a gap.
Do not propose names, directions, or positioning. Record instincts; save opinions for `/brand-debate`.
Flag contradictions between chapters explicitly.
