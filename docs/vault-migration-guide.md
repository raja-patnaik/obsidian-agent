# Vault Migration Guide

How to convert an existing Obsidian vault into the Claude-integrated format.

This guide is written for a Claude Code agent performing the migration. If you're a human, you can follow these steps manually or ask Claude Code to do it for you.

---

## Pre-Migration Checklist

Before starting, gather this information:

1. **Vault path**: Where is the vault on disk?
2. **Backup**: Has the user backed up their vault? (Git commit, zip, or copy.)
3. **Vault type**: Is this a work vault or personal vault?
4. **Existing plugins**: What Obsidian plugins are installed? (Check `.obsidian/community-plugins.json`)
5. **Existing templates**: Are there existing templates in use?
6. **Existing tags**: What tags are already in use? (Scan frontmatter and inline tags)

**CRITICAL: Always create a backup before migrating.**

```bash
# Create a timestamped backup
cp -r /path/to/vault /path/to/vault-backup-$(date +%Y%m%d-%H%M%S)
```

---

## Phase 1: Create the Folder Structure

Create the standard folder hierarchy. Don't move any files yet.

```bash
VAULT="/path/to/vault"

# Core folders (both vaults)
mkdir -p "$VAULT"/{00-inbox,01-daily,02-projects,03-areas,04-resources/{articles,bookmarks,how-tos},05-people,06-meetings,07-ideas,08-archive,_templates,_attachments}
```

For **work** vaults, also create:
```bash
mkdir -p "$VAULT"/03-areas/{team,processes,goals}
mkdir -p "$VAULT"/{09-decisions,10-standups}
```

For **personal** vaults, also create:
```bash
mkdir -p "$VAULT"/03-areas/{health,finance,learning,home}
mkdir -p "$VAULT"/{09-journal,10-lists}
```

Create year/month subdirectories for date-organized notes:
```bash
YEAR=$(date +%Y)
MONTH=$(date +%m)
mkdir -p "$VAULT"/01-daily/$YEAR/$MONTH
mkdir -p "$VAULT"/06-meetings/$YEAR/$MONTH
```

---

## Phase 2: Audit Existing Notes

Before moving files, analyze what's there.

### Step 2.1: Inventory all markdown files

```bash
find "$VAULT" -name "*.md" -not -path "*/.obsidian/*" | wc -l
```

### Step 2.2: Check for existing frontmatter

```bash
# Count files WITH frontmatter
find "$VAULT" -name "*.md" -not -path "*/.obsidian/*" -exec head -1 {} \; | grep -c "^---$"

# Count files WITHOUT frontmatter
find "$VAULT" -name "*.md" -not -path "*/.obsidian/*" -exec head -1 {} \; | grep -vc "^---$"
```

### Step 2.3: Catalog existing tags

```bash
# Find all tags in frontmatter and body
grep -roh '#[a-zA-Z][a-zA-Z0-9_/-]*' "$VAULT"/*.md "$VAULT"/**/*.md 2>/dev/null | sort | uniq -c | sort -rn
```

### Step 2.4: Classify notes by content

Read each note and classify it into one of these types based on its content:

| If the note looks like... | Assign type | Move to |
|---------------------------|-------------|---------|
| A date-titled daily entry | `daily` | `01-daily/YYYY/MM/` |
| Meeting minutes with attendees | `meeting` | `06-meetings/YYYY/MM/` |
| A project plan or tracker | `project` | `02-projects/project-name/` |
| An ongoing responsibility | `area` | `03-areas/` |
| An article, link, or how-to | `resource` | `04-resources/` |
| Notes about a person | `person` | `05-people/` |
| A random idea or brain dump | `idea` | `07-ideas/` |
| A decision record | `decision` | `09-decisions/` |
| A standup update | `standup` | `10-standups/` |
| A personal journal entry | `journal` | `09-journal/` |
| A list (wishlist, etc.) | `list` | `10-lists/` |
| Can't determine | leave as-is | `00-inbox/` |

---

## Phase 3: Add/Fix Frontmatter

For each note, add or update frontmatter according to the schema.

### Step 3.1: Notes with NO frontmatter

For each file missing frontmatter, analyze its content and add the appropriate schema:

```python
# Pseudocode for the agent
for note in notes_without_frontmatter:
    note_type = classify_note(note.content)
    frontmatter = generate_frontmatter(note_type, note)
    prepend_frontmatter(note, frontmatter)
```

When generating frontmatter:
- Set `created` from the file's creation date (or earliest date mentioned in content)
- Set `modified` from the file's last modification date
- Infer `tags` from content (look for inline #tags and topic keywords)
- Set `vault` to "work" or "personal" based on which vault this is
- Fill in type-specific fields where you can infer them from content

### Step 3.2: Notes with EXISTING frontmatter

For notes that already have frontmatter:
1. Preserve all existing fields
2. Add any missing required fields from the schema
3. Normalize field names (e.g., `date` → `created`, `updated` → `modified`)
4. Convert `tags` from string to list if needed
5. Add the `type` field if missing
6. Ensure `tags` includes the type as the first tag

Common migrations:

| Old Field | New Field | Notes |
|-----------|-----------|-------|
| `date` | `created` | Keep both if they differ |
| `updated` | `modified` | |
| `category` | `type` | Map to valid type enum |
| `tag` | `tags` | Convert string to list |
| `author` | (keep) | Non-standard but harmless |

### Step 3.3: Validate

After processing, run the validation script:

```bash
python validate-frontmatter.py "$VAULT"
```

Fix any reported errors before proceeding.

---

## Phase 4: Rename Files

Rename files to follow the naming conventions.

Rules:
1. All lowercase
2. Kebab-case (hyphens between words)
3. No spaces
4. Date-prefixed for dated types (daily, meeting, decision, standup)
5. `firstname-lastname.md` for people
6. `idea-short-title.md` for ideas

```python
# Pseudocode
for note in all_notes:
    old_name = note.filename
    new_name = generate_standard_name(note.type, note.content, note.frontmatter)

    if old_name != new_name:
        # Update all wikilinks across the vault that reference old_name
        update_all_links(vault, old_name_stem, new_name_stem)
        rename(note, new_name)
```

**IMPORTANT**: When renaming, you MUST update all `[[wikilinks]]` across the entire vault that reference the old filename. Otherwise you'll create broken links.

Strategy for updating links:
```bash
# Find all files that reference the old name
OLD="Old Note Name"
NEW="old-note-name"
grep -rl "\[\[$OLD\]\]" "$VAULT" --include="*.md" | while read file; do
    sed -i "s/\[\[$OLD\]\]/\[\[$NEW\]\]/g" "$file"
    sed -i "s/\[\[$OLD|/\[\[$NEW|/g" "$file"  # Handle aliased links
done
```

---

## Phase 5: Move Files to Correct Folders

Now move files to their designated folders.

Order of operations:
1. Move people notes to `05-people/`
2. Move project notes to `02-projects/`
3. Move meeting notes to `06-meetings/YYYY/MM/`
4. Move daily notes to `01-daily/YYYY/MM/`
5. Move resources to `04-resources/`
6. Move ideas to `07-ideas/`
7. Move area notes to `03-areas/`
8. Move everything else to `00-inbox/`

After each move, update any relative links or embedded images.

```python
# Pseudocode
for note in all_notes:
    target_folder = determine_destination(note.type, note.frontmatter)
    if note.current_folder != target_folder:
        move(note, target_folder)
        update_attachment_paths(note)
```

---

## Phase 6: Move Attachments

Consolidate all non-markdown attachments into `_attachments/`.

```bash
# Find all non-md files that aren't in .obsidian or _attachments
find "$VAULT" -type f ! -name "*.md" ! -path "*/.obsidian/*" ! -path "*/_attachments/*" ! -path "*/.git/*"
```

For each attachment:
1. Move to `_attachments/`
2. Update all `![[embed]]` and `![]()` references across the vault

---

## Phase 7: Install Templates

Copy the standard templates into `_templates/`:

```bash
cp templates/work/* "$VAULT/_templates/"   # for work vault
cp templates/personal/* "$VAULT/_templates/"  # for personal vault
```

---

## Phase 8: Create CLAUDE.md

Place the `CLAUDE.md` file in the vault root. This file tells Claude Code how to work with this specific vault.

See the `CLAUDE.md` templates in this package for work and personal variants.

---

## Phase 9: Post-Migration Validation

Run these checks after migration:

1. **Health check**: `bash vault-health-check.sh "$VAULT"`
2. **Frontmatter validation**: `python validate-frontmatter.py "$VAULT"`
3. **Link integrity**: Open the vault in Obsidian and check for broken links (they show in red)
4. **Graph view**: Open Obsidian's graph view — it should show a connected graph, not isolated nodes
5. **Dataview test**: If Dataview is installed, run a test query:
   ````
   ```dataview
   TABLE type, status, tags
   FROM ""
   SORT created DESC
   LIMIT 20
   ```
   ````

---

## Phase 10: Set Up Ongoing Maintenance

1. Install Kepano's official obsidian-skills Claude Code plugin:
   ```bash
   /plugin marketplace add kepano/obsidian-skills
   /plugin install obsidian@obsidian-skills
   ```
   This gives Claude native understanding of Obsidian markdown, Bases, Canvas, and CLI commands.
2. Install QMD and create a collection for the migrated vault:
   ```bash
   npm install -g @tobilu/qmd
   qmd collection add /path/to/vault --name <work|personal>
   qmd context add <work|personal> "Description of what this vault contains"
   qmd embed
   ```
3. Install recommended Obsidian community plugins (see `plugin-guide.md`)
4. Configure Claude Code hooks (see `hooks/hook-configs.json`) — includes the `Stop` hook for QMD auto-indexing
5. Set up the daily note as homepage
4. Create your first daily note for today

---

## Troubleshooting

### "I have notes that don't fit any type"
Put them in `00-inbox/` with `type: resource` as a default. You can reclassify later.

### "Some notes are very long and cover multiple topics"
Split them. Create separate notes for each topic and link them together. Leave a summary in the original location with links to the split notes.

### "I have notes in nested folders I want to keep"
The folder structure is a recommendation, not a requirement. If you have a folder structure that works well for a specific area, keep it under `03-areas/` or `04-resources/`. The key requirement is that every note has proper frontmatter.

### "I have duplicate notes"
Identify the most complete version, merge any unique content from the other, archive the duplicate to `08-archive/`, and add an alias in the surviving note.

### "My daily notes use a different date format"
Rename them to `YYYY-MM-DD.md`. Update any links. The migration script can handle batch renames.

### "I have Templater syntax in my templates"
Keep it. The `{{date:...}}` syntax in our templates is compatible with Templater. If you use different Templater variables, adapt the templates to match.
