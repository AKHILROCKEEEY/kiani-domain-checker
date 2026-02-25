---
name: domain:help
description: Show available domain checker commands and usage examples.
---

<objective>
Display all available domain checker commands with descriptions and usage examples.
</objective>

<process>

Print the following help text:

---

## Domain Checker Commands

### `/domain:research` — Full Workflow
Run the complete brand naming and domain research pipeline:
1. Describe your project and choose themes
2. 8 language agents generate name candidates
3. Brand review filters weak names
4. DNS + WHOIS checks domain availability
5. Final review delivers a curated shortlist

```
/domain:research
```

### `/domain:check` — Check Domains
Check if specific domain names are available. Automatically filters against previously checked names.

```
/domain:check trouvon hamnava kinnate
/domain:check myproject
```

### `/domain:review` — Brand Review
Evaluate names against branding criteria using a mentor persona (Steve Jobs, Paul Rand, David Ogilvy, or custom).

```
/domain:review trouvon matchfolk pertavi
```

### `/domain:help` — This Help
Show this list of commands.

---

### Tracking Files

Results are stored in your project's `tasks/` directory:
- `tasks/domains-available.md` — Confirmed available domains with scores
- `tasks/domains-taken.md` — Confirmed taken domains
- `tasks/domains-rejected.md` — Names that failed brand review

### Requirements

- `host` command (DNS lookups) — included on macOS and most Linux
- `whois` command (domain registration checks) — included on macOS, install via package manager on Linux

### Uninstall

```
npx @kianilab/domain-checker --uninstall
```

</process>
