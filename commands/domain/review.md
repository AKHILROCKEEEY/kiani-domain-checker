---
name: domain:review
description: Run a brand review on provided names using a mentor persona. Evaluates names against rejection criteria without checking domains.
---

<objective>
Evaluate provided brand names through the brand review quality gate. Apply the chosen mentor's philosophy to determine which names are strong enough to proceed to domain checking.
</objective>

<execution_context>
Reference files:
- @__INSTALL_PATH__domain-checker/references/naming-rules.md — Scoring criteria and hard requirements
- @__INSTALL_PATH__domain-checker/references/brand-review.md — Review methodology and rejection patterns

Templates (for initializing tracking files if missing):
- `__INSTALL_PATH__domain-checker/templates/domains-rejected.md`
</execution_context>

<process>

## Step 1: Get Names

If the user provided names as arguments (e.g., `/domain:review trouvon matchfolk pertavi`), use those.

If no names were provided, ask: **"What brand names would you like me to review?"**

## Step 2: Choose Mentor

Ask: **"Who should be the brand review mentor? (Default: Steve Jobs. Others: Paul Rand, David Ogilvy, or describe your own principle)"**

If the user accepts the default or doesn't specify, use Steve Jobs.

## Step 3: Score Names

Score each name against the evaluation criteria from naming-rules.md:
- Memorable (1-5)
- Pronounceable (1-5)
- Distinct (1-5)
- Negative Check (1-5)

Check all hard requirements first. Any name that fails a hard requirement is immediately rejected.

## Step 4: Brand Review

Read `brand-review.md` and replace `{{MENTOR}}` with the chosen mentor.

Review each scored name against the rejection criteria:
- Compound-word sludge
- Variation-suffix names
- Pharmaceutical Latin
- Foreign-language alienation
- Frankenstein blends
- Forgettable / no spark

Be ruthless — a strong "maybe" is a "no."

## Step 5: Report Results

Present results using the review output format:

**Approved** — names that pass the quality bar, with a one-line endorsement from the mentor persona.

**Rejected** — names that fail, with the rejection reason.

## Step 6: Update Tracking

If `tasks/domains-rejected.md` exists, add rejected names to it with rejection reasons and today's date.

Suggest running `/domain:check` on the approved names.

</process>
