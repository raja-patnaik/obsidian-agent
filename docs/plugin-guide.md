# Recommended Plugins

These plugins complement the Claude-integrated vault system. They're ordered by importance — install at least the "Essential" tier.

---

## Pre-requisite: Kepano's Obsidian Skills (Claude Code Plugin)

Before installing Obsidian community plugins, install the official **obsidian-skills** Claude Code plugin by Steph Ango (Kepano), the CEO of Obsidian. This isn't an Obsidian plugin — it's a Claude Code plugin that teaches Claude the correct Obsidian file formats.

```bash
# Install via Claude Code plugin marketplace
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
```

This provides 5 skills:

- **obsidian-markdown** — Obsidian-flavored markdown: wikilinks, embeds, callouts, properties/frontmatter, tags, highlights, comments, LaTeX, Mermaid diagrams
- **obsidian-bases** — Obsidian Bases database files: views, filters, formulas, summaries
- **json-canvas** — JSON Canvas whiteboard files: nodes, edges, groups
- **obsidian-cli** — CLI for interacting with running Obsidian instances: read/create/search notes, manage tasks, properties, tags, and backlinks
- **defuddle** — Clean web page extraction into markdown (reduces token usage when clipping)

The `obsidian-cli` skill is particularly powerful — it lets Claude interact with your vault through a running Obsidian instance rather than just editing files on disk. This means Claude can trigger Obsidian features like template insertion, plugin commands, and search.

---

## Pre-requisite: QMD (Local Semantic Search)

Install QMD by Tobi Lütke — an on-device search engine that indexes your markdown notes for hybrid semantic + keyword search with LLM reranking.

```bash
# Install globally
npm install -g @tobilu/qmd
# or
bun install -g @tobilu/qmd
```

**Setup**:
```bash
# Create a collection for each vault
qmd collection add ~/obsidian-vaults/work --name work
qmd context add work "Work vault: projects, meetings, decisions, standups, people, ideas, resources"

qmd collection add ~/obsidian-vaults/personal --name personal
qmd context add personal "Personal vault: journal, health, finance, learning, ideas, lists, people"

# Build initial embeddings index
qmd embed
```

**How it integrates**: A Claude Code `Stop` hook runs `qmd embed` after every agent response, keeping the index fresh. The vault manager skill uses `qmd query` for intelligent search — so when you ask "what was that thing about the database migration?" it finds notes even if you used completely different words.

**Key commands**:
- `qmd query -c work "question"` — best quality search (BM25 + vectors + reranking)
- `qmd search -c work "keywords"` — fast keyword search
- `qmd vsearch -c personal "concept"` — semantic/conceptual search
- `qmd get "path/to/note.md"` — retrieve a specific document

---

## Obsidian Community Plugins

### Essential Tier

### 1. Dataview
**What it does**: Query your notes like a database using frontmatter fields.
**Why you need it**: Your notes have structured frontmatter specifically designed for Dataview. This lets you create dynamic views like "all active projects," "people I haven't contacted in 30 days," or "this week's meetings."

**Key settings**:
- Enable JavaScript queries: ON (for more complex queries)
- Enable inline queries: ON
- Date format: `yyyy-MM-dd`

**Example queries to add to your vault**:

Active projects dashboard (add to a note or area page):
````markdown
```dataview
TABLE status, priority, target-date, owner
FROM "02-projects"
WHERE type = "project" AND status = "active"
SORT priority ASC
```
````

Recent meetings:
````markdown
```dataview
TABLE attendees, project, status
FROM "06-meetings"
WHERE type = "meeting"
SORT created DESC
LIMIT 10
```
````

People CRM — who to follow up with:
````markdown
```dataview
TABLE company, role, relationship, last-contact
FROM "05-people"
WHERE type = "person" AND last-contact <= date(today) - dur(30 days)
SORT last-contact ASC
```
````

### 2. Templater
**What it does**: Powerful template system with dynamic date insertion, prompts, and automation.
**Why you need it**: Creates new notes from templates with auto-filled dates, prompts for title/type, and consistent structure.

**Key settings**:
- Template folder: `_templates`
- Trigger on new file creation: ON
- Enable folder templates (map folders to templates):
  - `01-daily/` → `_templates/daily-note.md`
  - `06-meetings/` → `_templates/meeting-note.md`
  - `02-projects/` → `_templates/project.md`
  - `05-people/` → `_templates/person.md`
  - `07-ideas/` → `_templates/idea.md`

### 3. Calendar
**What it does**: Visual calendar in the sidebar that links to daily notes.
**Why you need it**: Quick navigation to any day's notes. Click a date to open or create that daily note.

**Key settings**:
- Daily note format: `YYYY-MM-DD`
- Daily note folder: `01-daily`
- Weekly note format: leave blank (we don't use weekly notes by default)

### 4. Tasks
**What it does**: Aggregates all `- [ ]` tasks across your vault into queryable views.
**Why you need it**: Action items in meeting notes, project tasks, and daily todos all become searchable and filterable.

**Key settings**:
- Global filter: (leave empty to capture all tasks)
- Done date format: `YYYY-MM-DD`

**Example task query** (add to daily note or a dashboard):
````markdown
```tasks
not done
due before tomorrow
group by filename
```
````

Overdue tasks:
````markdown
```tasks
not done
due before today
sort by due
```
````

---

## Highly Recommended

### 5. Periodic Notes
**What it does**: Extends daily notes to include weekly, monthly, quarterly, and yearly notes.
**Why you need it**: Great for weekly reviews and monthly summaries that the Claude agent can help generate.

**Key settings**:
- Daily notes folder: `01-daily/{{date:YYYY}}/{{date:MM}}`
- Daily notes format: `YYYY-MM-DD`
- Weekly notes: ON, folder: `01-daily/{{date:YYYY}}/weekly`
- Monthly notes: ON, folder: `01-daily/{{date:YYYY}}/monthly`

### 6. Quick Add
**What it does**: Capture notes quickly with configurable macros and shortcuts.
**Why you need it**: Rapidly create new notes of any type with a keyboard shortcut. Pairs perfectly with the template system.

**Suggested macros**:
- `Ctrl+Shift+M` → New meeting note (prompts for title, creates in `06-meetings/`)
- `Ctrl+Shift+I` → New idea (prompts for title, creates in `07-ideas/`)
- `Ctrl+Shift+P` → New person (prompts for name, creates in `05-people/`)
- `Ctrl+Shift+N` → Quick capture to inbox (`00-inbox/`)

### 7. Tag Wrangler
**What it does**: Rename, merge, and manage tags across your entire vault.
**Why you need it**: As your vault grows, tags drift. This plugin lets you batch-rename or merge tags to keep them consistent.

### 8. Natural Language Dates
**What it does**: Type dates in natural language (`@tomorrow`, `@next friday`) and they convert to proper dates.
**Why you need it**: Faster date entry in meeting notes and task due dates.

---

## Nice to Have

### 9. Kanban
**What it does**: Kanban boards as markdown files.
**Why you need it**: Visual project tracking. Each card is a note link, boards are stored as `.md` files that Claude can read and update.

**Suggested boards**:
- `02-projects/project-board.md` — Active projects by status
- `07-ideas/idea-board.md` — Ideas by status (seed → exploring → developing)

### 10. Graph Analysis
**What it does**: Enhanced graph view with clustering, centrality analysis.
**Why you need it**: See which notes are most connected (hubs), find isolated clusters, identify notes that bridge different topics.

### 11. Homepage
**What it does**: Set a custom homepage that opens when you launch Obsidian.
**Why you need it**: Set today's daily note as your homepage for a consistent starting point.

### 12. Obsidian Git
**What it does**: Auto-commit and push your vault to a Git repository.
**Why you need it**: Version control for your notes. Automatic backup. See what changed when. Claude Code can also interact with the git history.

**Key settings**:
- Auto-commit interval: 10 minutes
- Auto-push: ON
- Auto-pull on startup: ON
- Commit message format: `vault backup: {{date}}`

### 13. Linter
**What it does**: Enforce consistent markdown formatting.
**Why you need it**: Keeps your notes consistent — proper YAML frontmatter formatting, consistent heading styles, trailing whitespace removal.

**Key rules to enable**:
- YAML frontmatter sort: OFF (we have our own field order)
- YAML timestamp: ON (auto-update modified date)
- Heading blank lines: ON
- Trailing spaces: ON

---

## Plugin Compatibility Notes

All of these plugins work well together and with the Claude Code integration. A few things to keep in mind:

- **Dataview** reads the same frontmatter fields that Claude uses. Any note Claude creates or edits will appear correctly in Dataview queries.
- **Templater** and our template system use the same `_templates` folder. The `{{date:...}}` syntax is compatible with both.
- **Tasks** plugin reads standard markdown checkboxes that Claude also uses for action items.
- **Obsidian Git** ensures your vault is versioned, which makes Claude Code operations safer (you can always revert).

## Minimal Install

If you want to start small, install just these three:

1. **Dataview** — makes your structured frontmatter actually useful
2. **Templater** — consistent note creation
3. **Calendar** — easy daily note navigation

Add more as you find you need them.
