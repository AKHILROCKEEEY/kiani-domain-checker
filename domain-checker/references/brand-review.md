# Brand Review

## Purpose

Quality gate before burning WHOIS queries. Every candidate must pass this review before proceeding to domain checking. This prevents wasting rate-limited WHOIS lookups on names that would never survive brand scrutiny.

## Persona

Adopt the **{{MENTOR}}** philosophy for brand evaluation. You are not scoring names — you are feeling them. Ask: **"Would I put this on a billboard and not be embarrassed?"** If the answer isn't an immediate yes, it's a no.

### Adapting Your Review Voice

Match your review voice to the chosen mentor:

- **Steve Jobs**: "Would I put this on a billboard?" Obsess over simplicity, emotion, and whether the name makes you lean forward. Products should feel inevitable, not engineered.
- **Paul Rand**: "Does the mark reduce to its essence?" Focus on visual identity, how the name looks as a logo, whether it's timeless or trendy. Less is more — always.
- **David Ogilvy**: "Does it sell?" Think about the name in an ad headline, on a storefront, in a conversation. Is it memorable in the marketplace? Does it promise something?
- **Custom mentor**: Apply their stated principle as the quality bar. If someone says "Marie Kondo", ask "Does this name spark joy?" If "Dieter Rams", ask "Is this name as little design as possible?"

## Rejection Criteria

Kill any name that matches these patterns:

| Pattern | Why it fails | Example |
|---------|-------------|---------|
| **Compound-word sludge** | Descriptive, tells you what it does instead of making you feel something. "That's a feature description, not a brand." | matchfolk, folkmeet, threadmeet, folkfind |
| **Variation-suffix names** | A letter tacked onto a taken name. "The naming equivalent of putting a bumper sticker on a Honda." | madoii, sethui, bandhui, enishii |
| **Pharmaceutical Latin** | Latin coinages that sound like medication brands. "I'm checking the side effects." | pertavi, nectavi, congriva, amitora |
| **Foreign-language alienation** | 90% of the market has no phonetic intuition. Beautiful in origin language, meaningless to target audience. | rufeqa, tawamu, aumiva, niraivo |
| **Frankenstein blends** | Thesaurus in a blender. Nobody wakes up excited to tell their friend about it. | vicinara, commorah, warmada, villuno |
| **Forgettable / no spark** | Technically fine but generates zero emotional response. If you have to explain why it's good, it isn't. | tertulio, bonorde, sfiorato |

## Pre-Check Review Process

1. **Input:** Scored candidates from multi-agent research, sorted by Total score descending.
2. **Review each name** against the rejection criteria above. Be ruthless — a strong "maybe" is a "no."
3. **Approved names** proceed to domain checking.
4. **Rejected names** are added to `tasks/domains-rejected.md` with a one-line rejection reason.
5. **Never re-generate** rejected names — `dedup-check.sh` filters them automatically.

### Pre-Check Output Format

```markdown
## Brand Review (Pre-Check)

### Approved (proceed to domain check)
- **trouvon** — "French for 'let's find.' It has movement. It's an invitation."
- **gonuli** — "The willing heart. Short, warm, globally pronounceable."

### Rejected (added to domains-rejected.md)
| Name | Rejection Reason |
|------|------------------|
| matchfolk | Compound-word: descriptive, not emotional |
| pertavi | Sounds like a pharmaceutical brand |
```

## Post-Search Review (Final Cut)

### Purpose

Quality gate AFTER domain checking. Every domain that lands in `domains-available.md` gets one final review. This catches names that passed the pre-check but feel wrong when you see them sitting on the available list as a real option. Sometimes a name looks good in theory but once it's confirmed available, you see it differently — "Wait, I'd actually have to put this on a business card?"

### When to Run

Run this **every time** new domains are added to `domains-available.md` after a domain check completes. Review ONLY the newly added domains, not the entire file (previously approved domains already passed this gate).

### The Higher Bar

The question changes from "is this worth checking?" to **"Would I register this right now and build a company around it?"**

Names that might pass the pre-check but fail the final cut:

| Pattern | Why it fails now | Example |
|---------|-----------------|---------|
| **Available but forgettable** | It was "fine" as a candidate but you'd never love it. "Available isn't a reason to settle." | A name that scores 17 but generates zero excitement |
| **Available but unownable** | Too generic to build a brand around. You'd spend forever explaining it. | Common word fragments that happen to be free |
| **Available but no story** | No founder narrative. "If you can't explain why you named it that in one sentence, it's not a name — it's a placeholder." | Technically sound names with no emotional hook |
| **Available but wrong feel** | Doesn't match the product's soul. Cold when it should be warm. Corporate when it should be human. | Names that are technically excellent but emotionally wrong |

### Post-Search Output Format

```markdown
## Post-Search Brand Review (Final Cut)

### Approved (staying in domains-available.md)
- **trouvon** — "French for 'let's find.' It's an invitation. I'd put this on a billboard."
- **hokobi** — "A bud starting to bloom. That IS the product."

### Rejected (moved to domains-rejected.md)
| Name | Rejection Reason |
|------|------------------|
| somename | Available but forgettable — generates zero excitement |
```

## The Standard

> "The name should feel like a **feeling**, not a **description**. If someone hears it and asks 'what does your app do?' — you failed. If they hear it and say 'that's cool, what is that?' — you won."

> "We're not looking for a name that's available. We're looking for a name that's inevitable. If it doesn't make you lean forward in your chair, it's not the one."
