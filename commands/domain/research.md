---
name: domain:research
description: Full brand naming and domain research workflow. Generates name candidates across 8 languages, applies brand review, checks domain availability.
---

<objective>
Run the complete brand naming and domain research workflow: discover the user's project, generate names via multi-language agents, apply brand quality review, check domain availability, and deliver a curated shortlist of available .com domains.
</objective>

<execution_context>
Reference files (read these before starting):
- @__INSTALL_PATH__domain-checker/references/naming-rules.md — Hard requirements, scoring, creative tricks
- @__INSTALL_PATH__domain-checker/references/agent-roster.md — 8 language agent definitions
- @__INSTALL_PATH__domain-checker/references/brand-review.md — Brand review methodology

Scripts:
- `__INSTALL_PATH__domain-checker/scripts/dedup-check.sh` — Filter candidates against existing lists
- `__INSTALL_PATH__domain-checker/scripts/check-domains.sh` — DNS + WHOIS domain checker

Templates (for initializing tracking files):
- `__INSTALL_PATH__domain-checker/templates/domains-available.md`
- `__INSTALL_PATH__domain-checker/templates/domains-taken.md`
- `__INSTALL_PATH__domain-checker/templates/domains-rejected.md`
</execution_context>

<process>

## Phase 1: Discovery (Interactive)

Ask the user these questions one at a time. Wait for each answer before proceeding.

1. **"What is your project or idea? Describe it so I understand what we're naming."**
   - Get enough context to brief the naming agents properly.

2. **"What themes, feelings, or values should the name evoke?"**
   - Examples: connection, discovery, warmth, simplicity, craftsmanship, exploration, trust
   - These replace the `{{USER_THEMES}}` placeholder in agent-roster.md.

3. **"Any preferred languages to draw from? Default: Arabic, Farsi, English, Latin, Spanish, Italian, French, Japanese"**
   - If the user specifies languages, adjust the agent roster accordingly.
   - If they accept the default, use all 8 agents.

4. **"Who should be the brand review mentor? This persona sets the quality bar."**
   - Default: Steve Jobs
   - Other suggestions: Paul Rand, David Ogilvy, or "describe your own principle"
   - This replaces the `{{MENTOR}}` placeholder in brand-review.md.

5. **"Any constraints? (max length, industry, must include a specific sound, etc.)"**
   - Optional. Incorporate into agent briefs if provided.

## Phase 2: Initialize Tracking

Check if `tasks/domains-available.md`, `tasks/domains-taken.md`, and `tasks/domains-rejected.md` exist in the user's project. If not, create them from the templates.

## Phase 3: Multi-Agent Name Generation

1. Read `agent-roster.md` and replace `{{USER_THEMES}}` with the user's themes from Phase 1.
2. Read `naming-rules.md` for the full scoring and hard requirements.
3. Launch parallel research agents (one per language) using the Task tool with `subagent_type: "general-purpose"`. Each agent receives:
   - The naming rules (hard requirements + scoring + creative tricks)
   - Their language persona from the roster
   - The user's project description, themes, and constraints
   - Instructions to generate 10-15 candidates, romanize to ASCII, run hard requirements, and score survivors
4. Merge all agent results into a unified table sorted by Total score descending.

## Phase 4: Brand Review (Pre-Check)

1. Read `brand-review.md` and replace `{{MENTOR}}` with the user's chosen mentor.
2. Review all candidates against the rejection criteria using the mentor's persona.
3. Approved names proceed to Phase 5.
4. Rejected names go to `tasks/domains-rejected.md` with rejection reasons.

## Phase 5: Dedup + Domain Check

1. Run dedup check to filter out previously checked names:
   ```bash
   DOMAIN_TRACK_DIR="$PWD" bash __INSTALL_PATH__domain-checker/scripts/dedup-check.sh [candidates...]
   ```
2. Pipe surviving names through the domain checker:
   ```bash
   DOMAIN_TRACK_DIR="$PWD" bash __INSTALL_PATH__domain-checker/scripts/dedup-check.sh [candidates...] | bash __INSTALL_PATH__domain-checker/scripts/check-domains.sh
   ```
3. Update tracking files:
   - Available domains → `tasks/domains-available.md` (with scores)
   - Taken domains → `tasks/domains-taken.md`

## Phase 6: Post-Search Brand Review (Final Cut)

1. Apply the final brand review (from `brand-review.md` Post-Search section) to newly available domains.
2. The bar is higher now: "Would I register this right now and build a company around it?"
3. Approved names stay in `tasks/domains-available.md`.
4. Rejected names move to `tasks/domains-rejected.md`.

## Phase 7: Present Results

Show the user:
- Final approved available domains with scores and stories
- Summary stats (total generated, approved, rejected, available, taken)
- Recommendation of top 3-5 names with reasoning

</process>
