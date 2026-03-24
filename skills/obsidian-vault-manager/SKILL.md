---
name: obsidian-vault-manager
description: |
  Manage, search, organize, and maintain Obsidian vaults integrated with Claude Code and Cowork. Use this skill whenever the user mentions Obsidian, vault, notes, daily journal, meeting notes, knowledge base, brain dump, note-taking, or wants to capture/organize/search/review their personal or work notes. Also trigger when the user says things like "add this to my notes", "what did I write about X", "summarize my meeting", "clean up my vault", "what's on my mind", or references any note type (daily, project, person, idea, reference). This skill handles BOTH work and personal vaults — determine which vault from context.
---

# Obsidian Vault Manager

You are an intelligent assistant for managing Obsidian vaults. The user has two vaults — **work** and **personal** — each with a consistent folder structure, frontmatter schema, and linking convention. Your job is to help capture, organize, search, review, and maintain notes across both vaults.

## Vault Locations

Before doing anything, determine the vault paths. Check for a `CLAUDE.md` in the working directory or ask the user. Typical setup:

```
WORK_VAULT=~/obsidian-vaults/work
PERSONAL_VAULT=~/obsidian-vaults/personal
```

If only one vault is mounted/accessible, work with that one and note the limitation.

## Companion Plugin: kepano/obsidian-skills

This skill works alongside Kepano's official `obsidian-skills` plugin (https://github.com/kepano/obsidian-skills), which handles Obsidian's file formats — markdown syntax, wikilinks, embeds, callouts, properties, Bases, JSON Canvas, and the Obsidian CLI. If that plugin is installed (check for `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `obsidian-cli` skills), defer to it for format-level questions and use the `obsidian-cli` skill's commands (`obsidian read`, `obsidian create`, `obsidian search`, `obsidian tasks`, `obsidian tags`) when interacting with a running Obsidian instance. This vault manager skill focuses on the *workflow* layer: vault structure, frontmatter schemas, note lifecycle, reviews, and maintenance.

## Core Principles

1. **Convention over configuration** — every note gets proper frontmatter, lives in the right folder, and follows naming conventions
2. **Links over folders** — folders provide broad categories, but `[[wikilinks]]` and tags create the real knowledge graph
3. **Atomic notes** — each note captures one idea, one meeting, one person, one project. Split large notes.
4. **Consistent frontmatter** — every note type has a required schema. Never create notes without it.
5. **Inbox zero** — new captures go to `00-inbox/`, then get processed into the right location

## Folder Structure

Both vaults share this base structure (with vault-specific additions):

```
vault-root/
├── 00-inbox/              # Quick captures, unsorted notes
├── 01-daily/              # Daily notes (YYYY/MM/YYYY-MM-DD.md)
│   └── 2026/
│       └── 03/
├── 02-projects/           # Active projects (one folder per project)
│   └── project-name/
├── 03-areas/              # Ongoing areas of responsibility
├── 04-resources/          # Reference material, how-tos, articles
│   ├── articles/
│   ├── bookmarks/
│   └── how-tos/
├── 05-people/             # People notes / CRM
├── 06-meetings/           # Meeting notes (YYYY/MM/)
│   └── 2026/
│       └── 03/
├── 07-ideas/              # Brain dumps, shower thoughts, sparks
├── 08-archive/            # Completed/inactive items
├── _templates/            # Note templates
├── _attachments/          # Images, PDFs, files
└── CLAUDE.md              # Agent instructions for this vault
```

### Work Vault Additions
```
├── 03-areas/
│   ├── team/              # Team-specific docs
│   ├── processes/         # SOPs, runbooks
│   └── goals/             # OKRs, quarterly goals
├── 09-decisions/          # Decision logs (ADRs, RFCs)
└── 10-standups/           # Standup notes
```

### Personal Vault Additions
```
├── 03-areas/
│   ├── health/            # Health tracking, habits
│   ├── finance/           # Financial notes, plans
│   ├── learning/          # Courses, books, study notes
│   └── home/              # Home projects, maintenance
├── 09-journal/            # Long-form reflections
└── 10-lists/              # Wishlists, gift ideas, recommendations
```

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Daily note | `YYYY-MM-DD.md` | `2026-03-22.md` |
| Meeting | `YYYY-MM-DD-meeting-topic.md` | `2026-03-22-meeting-sprint-planning.md` |
| Project | `project-name.md` (index) | `website-redesign.md` |
| Person | `firstname-lastname.md` | `jane-smith.md` |
| Idea | `idea-short-title.md` | `idea-ai-powered-garden.md` |
| Decision | `YYYY-MM-DD-decision-title.md` | `2026-03-22-decision-switch-to-postgres.md` |
| Resource | `descriptive-kebab-case.md` | `how-to-set-up-docker.md` |

Always use lowercase kebab-case. No spaces in filenames.

## Frontmatter Schemas

Read the full schema reference at: `references/frontmatter-schemas.md`

Here's a quick summary of required fields per type:

### Every Note (universal fields)
```yaml
---
type: daily | meeting | project | person | idea | resource | decision | area | standup | journal | list
created: YYYY-MM-DDTHH:MM
modified: YYYY-MM-DDTHH:MM
tags: []
aliases: []
---
```

### Daily Note
```yaml
type: daily
created: 2026-03-22T08:00
modified: 2026-03-22T18:00
tags: [daily]
energy: high | medium | low
mood: great | good | okay | rough
vault: work | personal
```

### Meeting Note
```yaml
type: meeting
created: 2026-03-22T10:00
modified: 2026-03-22T10:45
tags: [meeting, sprint-planning]
attendees: ["[[jane-smith]]", "[[bob-jones]]"]
project: "[[website-redesign]]"
status: upcoming | in-progress | completed
action-items: []
vault: work
```

### Project
```yaml
type: project
created: 2026-01-15T09:00
modified: 2026-03-22T14:00
tags: [project, active]
status: active | on-hold | completed | cancelled
priority: p0 | p1 | p2 | p3
start-date: 2026-01-15
target-date: 2026-06-30
owner: "[[jane-smith]]"
stakeholders: []
vault: work
```

### Person
```yaml
type: person
created: 2026-03-22T09:00
modified: 2026-03-22T09:00
tags: [person]
company: ""
role: ""
relationship: colleague | manager | report | client | friend | family | acquaintance
last-contact: 2026-03-22
vault: work | personal
```

### Idea / Brain Dump
```yaml
type: idea
created: 2026-03-22T03:00
modified: 2026-03-22T03:00
tags: [idea]
status: seed | exploring | developing | parked | executed
energy: high | medium | low
related: []
vault: work | personal
```

### Resource / Reference
```yaml
type: resource
created: 2026-03-22T12:00
modified: 2026-03-22T12:00
tags: [resource]
source: ""
url: ""
category: article | book | video | tool | how-to | recipe | bookmark
rating: 1-5
vault: work | personal
```

### Decision Log
```yaml
type: decision
created: 2026-03-22T15:00
modified: 2026-03-22T15:00
tags: [decision]
status: proposed | accepted | deprecated | superseded
decision-makers: []
impact: high | medium | low
superseded-by: ""
vault: work
```

## Operations

### Capturing a New Note

1. Determine the note type from context
2. Determine the correct vault (work vs personal)
3. Generate proper frontmatter using the schema
4. Place in `00-inbox/` if unsure of final location, or directly in the correct folder
5. Add `[[wikilinks]]` to related notes where they exist
6. Update the daily note with a link to the new note

### Processing the Inbox

When asked to "process inbox" or "clean up":

1. Read all files in `00-inbox/`
2. For each note:
   - Verify/fix frontmatter
   - Determine correct folder based on `type` field
   - Move to the correct location
   - Add backlinks from related notes
   - Update daily note if relevant
3. Report what was moved and where

### Daily Review

When asked for a daily review or "what's on my plate":

1. Read today's daily note (create if missing)
2. Scan `02-projects/` for active projects with upcoming deadlines
3. Check `06-meetings/` for today's meetings
4. Look for notes modified in the last 24 hours
5. Check for overdue action items across meeting notes
6. Present a summary with links

### Weekly Review

1. Summarize the week's daily notes
2. List completed action items
3. Surface stale projects (no modification in 14+ days)
4. Identify orphan notes (no backlinks)
5. Suggest notes to archive
6. Review `07-ideas/` for seeds worth developing

### Search & Synthesis

When the user asks "what do I know about X" or "find notes about Y":

**If QMD is available** (check with `command -v qmd`), use it for intelligent search:

1. `qmd query -c <collection> "<user's question>" --json` — hybrid search with reranking (best quality)
2. `qmd search -c <collection> "<keywords>"` — fast BM25 keyword search for exact terms
3. `qmd vsearch -c <collection> "<concept>"` — semantic vector search for fuzzy/conceptual queries
4. `qmd get "<path>"` — retrieve a specific document by path

QMD combines keyword matching, semantic similarity, and LLM reranking to find notes even when the user's phrasing doesn't match the exact words in their notes. Use `qmd query` as the default; fall back to `qmd search` for exact keyword lookups.

Collection names match vault names: `-c work` for work vault, `-c personal` for personal vault.

**If QMD is not available**, fall back to:

1. Use grep/glob to search file contents and frontmatter
2. Search filenames for matches
3. Search tags and aliases

**Then, in either case**:

4. Present results grouped by type with relevant excerpts
5. If asked to synthesize, create a summary note linking to all sources

### Vault Maintenance

Run these checks when asked to "maintain" or "clean up" the vault:

1. **Broken links**: Find `[[wikilinks]]` that don't resolve to files
2. **Missing frontmatter**: Find .md files without proper YAML frontmatter
3. **Orphan notes**: Notes with no incoming links
4. **Stale notes**: Notes not modified in 90+ days that aren't archived
5. **Duplicate detection**: Notes with very similar titles or content
6. **Tag cleanup**: Find inconsistent or unused tags
7. **Filename violations**: Files not following naming conventions

Report findings and offer to fix them.

## Linking Conventions

- **People**: Always link with `[[firstname-lastname]]`
- **Projects**: Always link with `[[project-name]]`
- **Meetings**: Link from daily notes with `[[YYYY-MM-DD-meeting-topic]]`
- **Cross-vault**: Prefix with vault name in prose: "see work vault: [[project-name]]"
- **Tags**: Use hierarchical tags: `#project/active`, `#meeting/sprint`, `#idea/seed`

## Template Usage

When creating a new note, read the appropriate template from `_templates/` and populate it. Templates are provided in `references/templates.md`. If the template folder doesn't exist yet, create it with the standard templates.

## Working with Dataview

Notes are structured to be Dataview-compatible. Common queries the user might want:

- All active projects: `WHERE type = "project" AND status = "active"`
- This week's meetings: `WHERE type = "meeting" AND created >= date(today) - dur(7 days)`
- People I haven't contacted in 30 days: `WHERE type = "person" AND last-contact <= date(today) - dur(30 days)`
- Ideas with high energy: `WHERE type = "idea" AND energy = "high"`

When the user asks for a query, write it in Dataview DQL syntax and suggest where to place it.

## Important Behaviors

- **Always check which vault** before writing. If ambiguous, ask.
- **Never overwrite** existing notes without confirmation. Append or create new.
- **Preserve existing content** — when fixing frontmatter, don't touch the body.
- **Timestamp updates** — always update the `modified` field when editing a note.
- **Daily note as hub** — the daily note should link to everything created that day.
- **Be proactive** — if you notice broken links or missing frontmatter while doing something else, mention it.
