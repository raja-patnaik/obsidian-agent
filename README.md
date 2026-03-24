# Obsidian + Claude System

A complete system for managing Obsidian vaults with Claude Code and Cowork. Designed for two vaults (work and personal) with consistent structure, frontmatter schemas, agent skills, automation hooks, and migration tooling.

## What's Included

```
obsidian-claude-system/
├── skills/
│   └── obsidian-vault-manager/
│       ├── SKILL.md                          # Claude Code skill definition
│       ├── references/
│       │   ├── frontmatter-schemas.md        # Complete YAML schema for all note types
│       │   └── templates.md                  # Note body templates
│       └── scripts/
│           ├── vault-health-check.sh         # Vault health audit script
│           └── process-inbox.py              # Auto-sort inbox notes
├── hooks/
│   ├── hook-configs.json                     # Claude Code hook configuration (incl. QMD Stop hook)
│   ├── update-modified.py                    # Auto-update modified timestamps
│   ├── link-to-daily.py                      # Auto-link new notes to daily note
│   └── validate-frontmatter.py              # Frontmatter validation
├── templates/
│   ├── work/CLAUDE.md                        # Agent instructions for work vault
│   └── personal/CLAUDE.md                    # Agent instructions for personal vault
├── scripts/
│   └── setup-vault.sh                        # Vault bootstrapping script
├── docs/
│   ├── vault-migration-guide.md              # How to convert an existing vault
│   └── plugin-guide.md                       # Recommended Obsidian plugins
└── README.md                                 # This file
```

## Quick Start

### 1. Install Kepano's Official Obsidian Skills Plugin

This is the foundation — it teaches Claude the correct Obsidian file formats (markdown
syntax, wikilinks, callouts, Bases, JSON Canvas, and the Obsidian CLI). Install it first:

```bash
# From the Claude Code plugin marketplace
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
```

Or install manually by cloning into your vault's `.claude/` folder:
```bash
cd ~/obsidian-vaults/work
git clone https://github.com/kepano/obsidian-skills.git .claude/skills/obsidian-skills
```

This gives Claude 5 skills: `obsidian-markdown` (wikilinks, embeds, callouts, properties),
`obsidian-bases` (database views, filters, formulas), `json-canvas` (whiteboards),
`obsidian-cli` (read/create/search notes via CLI), and `defuddle` (clean web clipping).

### 2. Install the Vault Manager Skill (this package)

This skill layers on top of Kepano's — it adds vault structure, workflows, frontmatter
schemas, and lifecycle management. Copy it into your Claude Code skills directory:

```bash
cp -r skills/obsidian-vault-manager ~/.claude/skills/
```

Or if using Cowork, place it in your mounted `.skills/skills/` directory.

**How the two skills work together**: Kepano's skills handle the *format layer* (how to
write correct Obsidian markdown, how to use the CLI, how to structure a .base file).
The vault manager handles the *workflow layer* (where notes go, what frontmatter to use,
how to do daily reviews, when to archive, how to process the inbox).

### 3. Install QMD (Local Semantic Search)

QMD by Tobi Lütke is a local search engine that indexes your vault for semantic search.
It combines BM25 keyword matching, vector search, and LLM reranking — all on-device.

```bash
# Install globally
npm install -g @tobilu/qmd
# or
bun install -g @tobilu/qmd
```

Set up a collection for each vault:
```bash
qmd collection add ~/obsidian-vaults/work --name work
qmd context add work "Work vault: projects, meetings, decisions, standups, people, ideas, resources"

qmd collection add ~/obsidian-vaults/personal --name personal
qmd context add personal "Personal vault: journal, health, finance, learning, ideas, lists, people"

# Build initial index
qmd embed
```

The `Stop` hook in `hooks/hook-configs.json` automatically runs `qmd embed` after every
Claude response, so the index stays fresh without blocking individual edits.

### 4. Set up new vaults

```bash
# Work vault
./scripts/setup-vault.sh ~/obsidian-vaults/work work

# Personal vault
./scripts/setup-vault.sh ~/obsidian-vaults/personal personal
```

### 5. Configure hooks

Add the hooks from `hooks/hook-configs.json` to your Claude Code settings:

```bash
# Edit your Claude Code settings
claude config edit
# OR
vim ~/.claude/settings.json
```

Merge the `hooks` object from `hook-configs.json` into your settings. This includes the
`Stop` hook that runs `qmd embed` after each agent turn.

### 6. Install Obsidian plugins

Open each vault in Obsidian and install the recommended plugins from `docs/plugin-guide.md`. At minimum: Dataview, Templater, and Calendar.

### 7. Migrate existing notes (if applicable)

Follow the step-by-step process in `docs/vault-migration-guide.md`. Ask Claude Code to help:

```
"Help me migrate my existing Obsidian vault at ~/Documents/notes to the new format. It's my work vault."
```

## How It Works

### The Skill
The `obsidian-vault-manager` skill teaches Claude Code how to work with your vaults. It understands the folder structure, frontmatter schemas, naming conventions, and linking patterns. When you say things like "take meeting notes" or "what's on my plate," the skill kicks in.

### QMD Search
QMD indexes your vaults locally for semantic search. When you ask "what did I write about that architecture discussion last month," QMD finds the right notes even if your phrasing doesn't match the exact words. The `Stop` hook runs `qmd embed` once after each Claude response — so the index stays current without slowing down individual edits.

### The Hooks
Hooks automate housekeeping:
- **QMD re-index** (`Stop`): Runs `qmd embed` after each agent turn to keep the search index fresh
- **Modified timestamp** (`PostToolUse`): Auto-updates when you edit a note through Claude
- **Daily note linking** (`PostToolUse`): New notes automatically get linked from today's daily note
- **Frontmatter validation**: Catches schema violations before they accumulate

### The CLAUDE.md
Each vault has a `CLAUDE.md` at its root. This is the first thing Claude reads when it opens the vault. It contains vault-specific instructions, common tasks, and tag taxonomies.

### Two Vaults, One System
Work and personal vaults share the same structure and conventions but have different folder additions and different CLAUDE.md instructions. The skill handles both — it determines which vault to use based on context.

## Customization

This system is designed as a starting point. Customize it:

- **Add note types**: Define new frontmatter schemas in `references/frontmatter-schemas.md`
- **Add tags**: Update the tag taxonomies in each vault's `CLAUDE.md`
- **Add areas**: Create new subfolders under `03-areas/` for your specific responsibilities
- **Modify templates**: Edit `references/templates.md` and copy to `_templates/`
- **Add hooks**: Extend `hook-configs.json` with your own automation

## Note Types at a Glance

| Type | Folder | Use For |
|------|--------|---------|
| daily | 01-daily/ | Daily log, intentions, reflection |
| project | 02-projects/ | Project plans, tracking, milestones |
| area | 03-areas/ | Ongoing responsibilities |
| resource | 04-resources/ | Articles, how-tos, bookmarks |
| person | 05-people/ | People notes, CRM |
| meeting | 06-meetings/ | Meeting notes with attendees and action items |
| idea | 07-ideas/ | Brain dumps, sparks, explorations |
| decision | 09-decisions/ | Decision records (work vault) |
| standup | 10-standups/ | Daily standup notes (work vault) |
| journal | 09-journal/ | Long-form reflection (personal vault) |
| list | 10-lists/ | Wishlists, recommendations (personal vault) |
