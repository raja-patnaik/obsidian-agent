# Frontmatter Schema Reference

This document defines the complete YAML frontmatter schema for every note type in the Obsidian vault system. Frontmatter appears between `---` fences at the top of every `.md` file.

## Table of Contents

1. [Universal Fields](#universal-fields)
2. [Daily Note](#daily-note)
3. [Meeting Note](#meeting-note)
4. [Project](#project)
5. [Area](#area)
6. [Resource](#resource)
7. [Person](#person)
8. [Idea / Brain Dump](#idea--brain-dump)
9. [Decision Log](#decision-log)
10. [Standup](#standup)
11. [Journal (Personal)](#journal-personal)
12. [List (Personal)](#list-personal)

---

## Universal Fields

Every note MUST include these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | enum | yes | Note type identifier. One of: `daily`, `meeting`, `project`, `area`, `resource`, `person`, `idea`, `decision`, `standup`, `journal`, `list` |
| `created` | datetime | yes | ISO 8601 timestamp of creation: `YYYY-MM-DDTHH:MM` |
| `modified` | datetime | yes | ISO 8601 timestamp of last modification |
| `tags` | list[string] | yes | Tag list. Always include the type as first tag. Use kebab-case. |
| `aliases` | list[string] | no | Alternative names for this note (helps with search and linking) |
| `vault` | enum | no | `work` or `personal`. Useful when cross-referencing. |

---

## Daily Note

The daily note is the anchor of each day. It links to everything created or referenced that day.

```yaml
---
type: daily
created: 2026-03-22T08:00
modified: 2026-03-22T18:00
tags: [daily]
aliases: ["Saturday March 22"]
energy: high          # high | medium | low — overall energy level
mood: good            # great | good | okay | rough
weather: sunny        # optional, personal vault
vault: personal
---
```

### Body Structure

```markdown
# 2026-03-22 Saturday

## Morning Intentions
- [ ] Top 3 things I want to accomplish

## Log
- 09:00 — [[2026-03-22-meeting-sprint-planning|Sprint Planning]]
- 10:30 — Worked on [[website-redesign]]
- 14:00 — Call with [[jane-smith]]

## Notes Created Today
- [[idea-ai-powered-garden]]
- [[how-to-set-up-docker]]

## End of Day Reflection
What went well? What could improve?

## Gratitude
-
```

---

## Meeting Note

```yaml
---
type: meeting
created: 2026-03-22T10:00
modified: 2026-03-22T10:45
tags: [meeting, sprint-planning]
aliases: ["Sprint Planning Mar 22"]
attendees:
  - "[[jane-smith]]"
  - "[[bob-jones]]"
project: "[[website-redesign]]"
status: completed     # upcoming | in-progress | completed | cancelled
recurring: true       # whether this is a recurring meeting
cadence: biweekly     # weekly | biweekly | monthly | quarterly (if recurring)
action-items:
  - task: "Review the wireframes"
    owner: "[[jane-smith]]"
    due: 2026-03-25
    done: false
  - task: "Set up staging environment"
    owner: "[[raja]]"
    due: 2026-03-24
    done: false
vault: work
---
```

### Body Structure

```markdown
# Sprint Planning — 2026-03-22

## Context
Why this meeting happened, what we're trying to decide/review.

## Discussion
Key points discussed. Use bullet points for discrete topics.

## Decisions
- Decision 1: We'll use React for the frontend
- Decision 2: Deploy to AWS instead of GCP

## Action Items
- [ ] [[jane-smith]]: Review the wireframes by 2026-03-25
- [ ] [[raja]]: Set up staging environment by 2026-03-24

## Follow-up
Next meeting: [[2026-04-05-meeting-sprint-planning]]
```

---

## Project

```yaml
---
type: project
created: 2026-01-15T09:00
modified: 2026-03-22T14:00
tags: [project, active, q1-2026]
aliases: ["Site Redesign", "New Website"]
status: active        # active | on-hold | completed | cancelled
priority: p1          # p0 (critical) | p1 (high) | p2 (medium) | p3 (low)
start-date: 2026-01-15
target-date: 2026-06-30
end-date:             # filled when completed
owner: "[[raja]]"
stakeholders:
  - "[[jane-smith]]"
  - "[[cto-team]]"
area: "[[engineering]]"
vault: work
---
```

### Body Structure

```markdown
# Website Redesign

## Objective
One-sentence description of what success looks like.

## Background
Why this project exists. Link to decision: [[2026-01-10-decision-redesign-website]]

## Key Results
- [ ] Homepage load time < 2s
- [ ] Mobile conversion rate +15%
- [ ] Launch by 2026-06-30

## Milestones
| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Design approved | 2026-02-15 | done |
| Frontend complete | 2026-04-30 | in-progress |
| Launch | 2026-06-30 | pending |

## Related
- Meetings: [[2026-03-22-meeting-sprint-planning]]
- Decisions: [[2026-01-10-decision-redesign-website]]
- People: [[jane-smith]], [[bob-jones]]

## Log
- 2026-03-22: Sprint planning done, frontend on track
- 2026-03-15: Design review passed
```

---

## Area

```yaml
---
type: area
created: 2026-01-01T00:00
modified: 2026-03-22T12:00
tags: [area]
aliases: []
description: "Ongoing area of responsibility"
vault: work
---
```

### Body Structure

```markdown
# Engineering

## Description
What this area covers and why it matters.

## Active Projects
```dataview
TABLE status, priority, target-date
FROM "02-projects"
WHERE area = link("engineering") AND status = "active"
SORT priority ASC
```

## Key Contacts
- [[jane-smith]] — Tech Lead
- [[bob-jones]] — Senior Engineer

## Processes
- [[code-review-process]]
- [[deployment-runbook]]
```

---

## Resource

```yaml
---
type: resource
created: 2026-03-22T12:00
modified: 2026-03-22T12:00
tags: [resource, docker, devops]
aliases: ["Docker Setup Guide"]
source: "Docker Documentation"
url: "https://docs.docker.com/get-started/"
author: ""
category: how-to      # article | book | video | tool | how-to | recipe | bookmark | course
rating: 4             # 1-5 scale
status: read          # unread | reading | read | reference
related-projects: []
vault: work
---
```

---

## Person

```yaml
---
type: person
created: 2026-03-22T09:00
modified: 2026-03-22T09:00
tags: [person, engineering]
aliases: ["Jane", "JS"]
first-name: Jane
last-name: Smith
company: "Acme Corp"
role: "Tech Lead"
email: "jane@acme.com"
phone: ""
linkedin: ""
relationship: colleague   # colleague | manager | report | client | friend | family | acquaintance | mentor | mentee
last-contact: 2026-03-22
met-at: "Onboarding 2024"
birthday:                 # personal vault
vault: work
---
```

### Body Structure

```markdown
# Jane Smith

## About
Tech Lead at Acme Corp. Reports to [[bob-jones]]. Works on [[website-redesign]].

## Key Info
- Prefers async communication
- Expert in React and TypeScript
- Timezone: PST

## Interaction Log
- 2026-03-22: Sprint planning, discussed frontend architecture
- 2026-03-15: 1:1, talked about career growth
- 2026-03-01: Met at team offsite

## Notes
- Interested in moving to a staff role
- Has a dog named Pixel
```

---

## Idea / Brain Dump

```yaml
---
type: idea
created: 2026-03-22T03:00
modified: 2026-03-22T03:00
tags: [idea, ai, gardening]
aliases: ["Smart Garden"]
status: seed          # seed | exploring | developing | parked | executed
energy: high          # how excited you are about this: high | medium | low
effort: medium        # estimated effort: low | medium | high | huge
impact: high          # potential impact: low | medium | high
related:
  - "[[website-redesign]]"
  - "[[ai-research]]"
vault: personal
---
```

### Body Structure

```markdown
# AI-Powered Garden Monitor

## The Spark
What if I could use a camera + AI to monitor my garden and tell me what each plant needs?

## Why This Excites Me
- Combines my love of gardening with AI
- Could be a fun weekend project
- Practical daily use

## Raw Thoughts
Just dump everything here. Don't filter. Stream of consciousness is fine.

## Next Steps
- [ ] Research existing solutions
- [ ] Look into Raspberry Pi camera modules
- [ ] Check if there's a plant identification API

## Related
- [[learning/machine-vision]]
- [[home/garden-plan-2026]]
```

---

## Decision Log

```yaml
---
type: decision
created: 2026-03-22T15:00
modified: 2026-03-22T15:00
tags: [decision, infrastructure]
aliases: ["Postgres Migration Decision"]
status: accepted      # proposed | accepted | deprecated | superseded
decision-makers:
  - "[[raja]]"
  - "[[jane-smith]]"
impact: high          # high | medium | low
reversibility: medium # easy | medium | hard | irreversible
superseded-by: ""     # link to newer decision if deprecated
related-project: "[[website-redesign]]"
vault: work
---
```

### Body Structure

```markdown
# Switch to PostgreSQL

## Context
What's the situation? Why does a decision need to be made?

## Decision
What was decided and why.

## Alternatives Considered
1. **Stay with MySQL** — Pros: no migration cost. Cons: missing JSONB, worse full-text search.
2. **Use MongoDB** — Pros: flexible schema. Cons: team has no experience.
3. **PostgreSQL** (chosen) — Pros: JSONB, extensions, team knows SQL. Cons: migration effort.

## Consequences
What changes as a result of this decision.

## Review Date
Revisit this decision by: 2026-09-22
```

---

## Standup

```yaml
---
type: standup
created: 2026-03-22T09:00
modified: 2026-03-22T09:05
tags: [standup]
sprint: "Sprint 12"
vault: work
---
```

### Body Structure

```markdown
# Standup — 2026-03-22

## Yesterday
- Completed wireframe review for [[website-redesign]]
- Fixed auth bug (#1234)

## Today
- Set up staging environment
- Start frontend migration

## Blockers
- Waiting on API keys from [[jane-smith]]
```

---

## Journal (Personal)

```yaml
---
type: journal
created: 2026-03-22T21:00
modified: 2026-03-22T21:30
tags: [journal, reflection]
mood: reflective      # any freeform mood word
prompt: ""            # optional journaling prompt
vault: personal
---
```

---

## List (Personal)

```yaml
---
type: list
created: 2026-03-22T10:00
modified: 2026-03-22T10:00
tags: [list, gifts]
category: gifts       # wishlist | gifts | restaurants | movies | books | travel | goals
vault: personal
---
```

---

## Validation Rules

When creating or editing notes, enforce these rules:

1. `type` must be one of the defined enums
2. `created` and `modified` must be valid ISO 8601 datetimes
3. `tags` must be a YAML list, not a comma-separated string
4. `status` values must match the enum for that type
5. `priority` (projects) must be p0–p3
6. Person links in `attendees`, `stakeholders`, etc. must use `"[[name]]"` format
7. `modified` must be >= `created`
8. File must be in the correct folder for its `type`
