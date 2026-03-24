# Note Templates

These are the standard templates for each note type. When creating a new note, use the appropriate template and fill in the frontmatter and body sections.

Templates should be placed in the `_templates/` folder of each vault.

---

## Daily Note Template

**Filename**: `_templates/daily-note.md`

```markdown
---
type: daily
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [daily]
energy:
mood:
vault: {{vault}}
---

# {{date:YYYY-MM-DD}} {{date:dddd}}

## Morning Intentions
- [ ]
- [ ]
- [ ]

## Log


## Notes Created Today


## End of Day Reflection


## Gratitude
-
```

---

## Meeting Note Template

**Filename**: `_templates/meeting-note.md`

```markdown
---
type: meeting
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [meeting]
attendees: []
project:
status: upcoming
recurring: false
cadence:
action-items: []
vault: {{vault}}
---

# {{title}} — {{date:YYYY-MM-DD}}

## Context


## Discussion


## Decisions


## Action Items
- [ ]

## Follow-up

```

---

## Project Template

**Filename**: `_templates/project.md`

```markdown
---
type: project
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [project, active]
status: active
priority: p2
start-date: {{date:YYYY-MM-DD}}
target-date:
end-date:
owner:
stakeholders: []
area:
vault: {{vault}}
---

# {{title}}

## Objective


## Background


## Key Results
- [ ]

## Milestones
| Milestone | Target Date | Status |
|-----------|-------------|--------|
|           |             |        |

## Related


## Log
- {{date:YYYY-MM-DD}}: Project created
```

---

## Person Template

**Filename**: `_templates/person.md`

```markdown
---
type: person
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [person]
first-name:
last-name:
company:
role:
email:
phone:
linkedin:
relationship:
last-contact: {{date:YYYY-MM-DD}}
met-at:
birthday:
vault: {{vault}}
---

# {{first-name}} {{last-name}}

## About


## Key Info


## Interaction Log
- {{date:YYYY-MM-DD}}:

## Notes

```

---

## Idea Template

**Filename**: `_templates/idea.md`

```markdown
---
type: idea
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [idea]
status: seed
energy:
effort:
impact:
related: []
vault: {{vault}}
---

# {{title}}

## The Spark


## Why This Excites Me


## Raw Thoughts


## Next Steps
- [ ]

## Related

```

---

## Resource Template

**Filename**: `_templates/resource.md`

```markdown
---
type: resource
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [resource]
source:
url:
author:
category:
rating:
status: unread
related-projects: []
vault: {{vault}}
---

# {{title}}

## Summary


## Key Takeaways


## Quotes / Highlights


## How This Applies

```

---

## Decision Log Template

**Filename**: `_templates/decision.md`

```markdown
---
type: decision
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [decision]
status: proposed
decision-makers: []
impact:
reversibility:
superseded-by:
related-project:
vault: {{vault}}
---

# {{title}}

## Context


## Decision


## Alternatives Considered
1.
2.
3.

## Consequences


## Review Date

```

---

## Standup Template

**Filename**: `_templates/standup.md`

```markdown
---
type: standup
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [standup]
sprint:
vault: work
---

# Standup — {{date:YYYY-MM-DD}}

## Yesterday


## Today


## Blockers

```

---

## Journal Template (Personal)

**Filename**: `_templates/journal.md`

```markdown
---
type: journal
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [journal]
mood:
prompt:
vault: personal
---

# Journal — {{date:YYYY-MM-DD}}

## What's on my mind


## Reflection


## Tomorrow

```

---

## List Template (Personal)

**Filename**: `_templates/list.md`

```markdown
---
type: list
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [list]
category:
vault: personal
---

# {{title}}

-
```

---

## Area Template

**Filename**: `_templates/area.md`

```markdown
---
type: area
created: {{date:YYYY-MM-DDTHH:mm}}
modified: {{date:YYYY-MM-DDTHH:mm}}
tags: [area]
description:
vault: {{vault}}
---

# {{title}}

## Description


## Active Projects


## Key Contacts


## Processes

```
