# Multi-Agent Name Research

## Overview

Spawn **8 parallel research agents** to generate name candidates. Each agent adopts the persona of a **native speaker** of their assigned language and is fluent in English. They think in their native language, draw from cultural idioms, poetry, and everyday speech — then romanize findings into ASCII.

## Agent Roster

| Agent | Language | Persona |
|-------|----------|---------|
| 1 | **Arabic** | Native Arabic speaker (fluent English). Draws from Quranic vocabulary, everyday dialect, poetry, and calligraphic tradition. |
| 2 | **Farsi** | Native Farsi speaker (fluent English). Draws from Persian poetry (Rumi, Hafez), compound words, and colloquial expressions. |
| 3 | **English** | Native English speaker. Focuses on Anglo-Saxon roots, compound words, blends, and modern coinages. |
| 4 | **Latin** | Classical Latin specialist (fluent English). Draws from Latin roots, prefixes, suffixes, and Romance-family etymology. |
| 5 | **Spanish** | Native Spanish speaker (fluent English). Draws from Castilian vocabulary, regional idioms, and Latin American expressions. |
| 6 | **Italian** | Native Italian speaker (fluent English). Draws from Italian vocabulary, musical terms, and regional dialect. |
| 7 | **French** | Native French speaker (fluent English). Draws from French vocabulary, literary tradition, and Francophone culture. |
| 8 | **Japanese** | Native Japanese speaker (fluent English). Draws from Kanji compounds, Yamato kotoba (native words), and cultural concepts. |

## Agent Instructions

Each agent receives the same brief:

1. **Generate 10-15 candidate names** from your language that evoke: {{USER_THEMES}}
2. **Romanize** every name into plain ASCII (a-z only). The romanized form IS the brand name.
3. **Run Hard Requirements** (ASCII-only, single obvious spelling, no negative homophones, cross-language safety). Discard failures.
4. **Score each survivor** on the 4-point system: Memorable, Pronounceable, Distinct, Negative Check (1-5 each).
5. **Write findings** in the output format below.
6. Include for each candidate: Name, Origin, Meaning, Story (1-line founder narrative), and all 4 scores + Total.

## Agent Output Format

```markdown
## Agent: [Language]

| Name | Meaning | Story | Mem | Pron | Dist | Neg | Total |
|------|---------|-------|-----|------|------|-----|-------|
| example | togetherness | "It means X in Y — because Z" | 4 | 5 | 4 | 5 | 18 |
```

## Orchestration

1. Launch all 8 agents in parallel using the Task tool (`subagent_type: "general-purpose"`).
2. Once all agents complete, **merge results** into a unified candidates table sorted by Total score descending.
3. Run `dedup-check.sh` on all candidates to filter out names already in `domains-available.md`, `domains-taken.md`, or `domains-rejected.md`.
4. Run the **Brand Review** on surviving candidates. Rejected names go to `tasks/domains-rejected.md`.
5. Proceed to domain checking with only approved names.
6. After domain checking completes, run the **Post-Search Brand Review** on newly available domains. Rejected names move from `domains-available.md` to `domains-rejected.md`.
