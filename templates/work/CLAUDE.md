# CLAUDE.md — Work Vault

This is the work Obsidian vault for Raja. Claude Code agents should read this file first when working with this vault.

## Vault Info

- **Vault type**: work
- **Owner**: Raja (patnaik.raja@gmail.com)
- **Path**: (update with actual path)
- **Companion vault**: personal vault at (update with actual path)

## Installed Skills

- **kepano/obsidian-skills** — Official Obsidian plugin for file formats (markdown, Bases, Canvas, CLI). Use `obsidian-cli` commands (`obsidian read`, `obsidian create`, `obsidian search`) when Obsidian is running.
- **obsidian-vault-manager** — Vault structure, frontmatter schemas, workflows, reviews, maintenance.
- **QMD** (`@tobilu/qmd`) — Local semantic search. Use `qmd query -c work "<question>"` for intelligent search across this vault. The index auto-updates after each agent response via a `Stop` hook.

## Folder Structure

```
00-inbox/        → Quick captures, unsorted notes (process regularly)
01-daily/        → Daily notes: 01-daily/YYYY/MM/YYYY-MM-DD.md
02-projects/     → Active projects: 02-projects/project-name/project-name.md
03-areas/        → Ongoing areas: team/, processes/, goals/
04-resources/    → Reference material: articles/, bookmarks/, how-tos/
05-people/       → People/CRM: firstname-lastname.md
06-meetings/     → Meeting notes: 06-meetings/YYYY/MM/YYYY-MM-DD-meeting-topic.md
07-ideas/        → Brain dumps: idea-short-title.md
08-archive/      → Completed/inactive items
09-decisions/    → Decision logs: YYYY-MM-DD-decision-title.md
10-standups/     → Standup notes
_templates/      → Note templates
_attachments/    → Images, PDFs, files
```

## Rules for Agents

1. **Every note needs frontmatter** — See the skill reference for schemas per type
2. **Always update `modified`** — When editing any note, update the modified timestamp
3. **Use wikilinks** — Link to people with `[[firstname-lastname]]`, projects with `[[project-name]]`
4. **Daily note is the hub** — Link all new notes from the daily note
5. **Inbox is temporary** — Notes in `00-inbox/` should be processed within a day
6. **Never delete without asking** — Move to `08-archive/` instead
7. **Kebab-case filenames** — All lowercase, hyphens between words
8. **Ask before cross-vault operations** — Don't modify the personal vault from here

## Common Tasks

### "What's on my plate today?"
1. Check today's daily note in `01-daily/`
2. List active projects from `02-projects/` (status: active)
3. Check today's meetings in `06-meetings/`
4. Surface overdue action items from recent meeting notes

### "Take meeting notes"
1. Create note in `06-meetings/YYYY/MM/YYYY-MM-DD-meeting-topic.md`
2. Use meeting template frontmatter
3. Link attendees as `[[firstname-lastname]]`
4. Link to project if applicable
5. Add action items with owners and due dates
6. Add link from today's daily note

### "Add this person"
1. Create in `05-people/firstname-lastname.md`
2. Use person template
3. Fill in known fields
4. Add to daily note's interaction log

### "Log a decision"
1. Create in `09-decisions/YYYY-MM-DD-decision-title.md`
2. Use decision template
3. Link to relevant project and people
4. Record alternatives considered

## Tags in Use

Work vault uses these tag hierarchies:
- `#project/active`, `#project/on-hold`, `#project/completed`
- `#meeting/standup`, `#meeting/1on1`, `#meeting/planning`, `#meeting/review`
- `#decision/accepted`, `#decision/proposed`
- `#area/engineering`, `#area/product`, `#area/design`
- `#priority/p0`, `#priority/p1`, `#priority/p2`, `#priority/p3`

## Dataview Queries

These are pre-built queries agents can suggest or use:

**Active projects**: `FROM "02-projects" WHERE status = "active" SORT priority ASC`
**This week's meetings**: `FROM "06-meetings" WHERE created >= date(today) - dur(7 days) SORT created DESC`
**Open action items**: Search for `- [ ]` across `06-meetings/`
**Stale contacts**: `FROM "05-people" WHERE last-contact <= date(today) - dur(30 days)`
