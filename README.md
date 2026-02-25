# @kianilab/domain-checker

Brand name research and domain availability checker for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Generates brand name candidates across 8 languages, applies a rigorous brand review, and checks `.com` domain availability via DNS + WHOIS — all from inside Claude Code.

## Install

```bash
npx @kianilab/domain-checker@latest
```

Choose global (`~/.claude/`) or local (`./.claude/`) installation. Claude Code auto-discovers the commands.

### Flags

```bash
npx @kianilab/domain-checker --global      # Install to ~/.claude/
npx @kianilab/domain-checker --local       # Install to ./.claude/
npx @kianilab/domain-checker --uninstall   # Remove from both locations
npx @kianilab/domain-checker --help        # Show help
```

## Commands

| Command | Description |
|---------|-------------|
| `/domain:research` | Full workflow — discovery, multi-language name generation, brand review, domain checking |
| `/domain:check` | Check specific domain names for availability |
| `/domain:review` | Brand review gate — evaluate names against quality criteria |
| `/domain:help` | Show all commands and usage |

## Usage

### Full Research Workflow

```
/domain:research
```

This walks you through:

1. **Describe your project** — what are you building?
2. **Set your themes** — what feelings should the name evoke?
3. **Choose languages** — which languages to draw from (default: 8 languages)
4. **Pick a mentor** — who sets the quality bar? (default: Steve Jobs)
5. **Set constraints** — max length, industry, specific sounds

Then it automatically:
- Launches 8 parallel language agents to brainstorm names
- Applies the brand review to filter weak candidates
- Checks domain availability via DNS + WHOIS
- Runs a final quality review on available domains
- Delivers a curated shortlist with scores and stories

### Quick Domain Check

```
/domain:check trouvon hamnava kinnate
```

Checks if specific `.com` domains are available. Automatically skips names already in your tracking files.

### Brand Review Only

```
/domain:review trouvon matchfolk pertavi
```

Evaluates names against branding criteria without checking domains. Choose a mentor persona to set the quality bar.

## Tracking Files

Results are stored in your project's `tasks/` directory:

| File | Contents |
|------|----------|
| `tasks/domains-available.md` | WHOIS-confirmed available domains with scores |
| `tasks/domains-taken.md` | Confirmed taken domains |
| `tasks/domains-rejected.md` | Names that failed brand review |

These files persist across sessions and the dedup filter automatically skips previously checked names.

## Requirements

- **Node.js** >= 16.7.0 (for the installer)
- **`host`** command — DNS lookups (included on macOS and most Linux)
- **`whois`** command — domain registration checks (included on macOS; on Linux: `apt install whois` or `yum install whois`)

## How It Works

### Name Generation
8 parallel agents, each a native speaker of a different language (Arabic, Farsi, English, Latin, Spanish, Italian, French, Japanese), brainstorm names that evoke your themes. They romanize everything to ASCII and score candidates on memorability, pronounceability, distinctiveness, and cross-language safety.

### Brand Review
A configurable mentor persona (Steve Jobs by default) reviews every candidate. Names that feel like "feature descriptions" rather than brands get rejected. The bar is high — a strong "maybe" is a "no."

### Domain Checking
A 2-stage pipeline: DNS first (fast, no rate limit), then WHOIS only for unresolved names (slow, rate-limited). Available domains get a final brand review at the higher bar of "would I actually register this?"

## Uninstall

```bash
npx @kianilab/domain-checker --uninstall
```

This removes the `commands/domain/` and `domain-checker/` directories from both `~/.claude/` and `./.claude/`.

## License

MIT
