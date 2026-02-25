---
name: domain:check
description: Check domain availability for specific names. Runs dedup filter then DNS + WHOIS pipeline. Usage: /domain:check name1 name2 name3
---

<objective>
Check domain availability for the provided names using the DNS + WHOIS pipeline. Filter against existing tracking lists first, then check new names and update tracking files.
</objective>

<execution_context>
Scripts:
- `__INSTALL_PATH__domain-checker/scripts/dedup-check.sh` — Filter candidates against existing lists
- `__INSTALL_PATH__domain-checker/scripts/check-domains.sh` — DNS + WHOIS domain checker

Templates (for initializing tracking files if missing):
- `__INSTALL_PATH__domain-checker/templates/domains-available.md`
- `__INSTALL_PATH__domain-checker/templates/domains-taken.md`
- `__INSTALL_PATH__domain-checker/templates/domains-rejected.md`
</execution_context>

<process>

## Step 1: Get Names

If the user provided names as arguments (e.g., `/domain:check google apple newbrand`), use those.

If no names were provided, ask: **"What domain names would you like to check? (space-separated, .com is assumed)"**

## Step 2: Initialize Tracking

Check if `tasks/domains-available.md`, `tasks/domains-taken.md`, and `tasks/domains-rejected.md` exist. If not, create them from the templates.

## Step 3: Dedup Check

Run the dedup filter to skip names already in the tracking files:
```bash
DOMAIN_TRACK_DIR="$PWD" bash __INSTALL_PATH__domain-checker/scripts/dedup-check.sh [names...]
```

Report any skipped names to the user.

## Step 4: Domain Check

For new names that passed dedup, run the domain checker:
```bash
DOMAIN_TRACK_DIR="$PWD" bash __INSTALL_PATH__domain-checker/scripts/dedup-check.sh [names...] | bash __INSTALL_PATH__domain-checker/scripts/check-domains.sh
```

## Step 5: Update Tracking Files

- Available domains → add to `tasks/domains-available.md`
- Taken domains → add to `tasks/domains-taken.md`
- Include the date checked

## Step 6: Report Results

Show the user a summary of results: which names are available, which are taken, and which were already known.

</process>
