# Claude Code Hooks for Obsidian Vault Management

These hooks automate vault maintenance tasks when using Claude Code with your Obsidian vaults.

## Installation

Add the hooks from `hook-configs.json` to your Claude Code configuration:

```bash
# Global (all projects)
vim ~/.claude/settings.json

# Or project-level
vim .claude/settings.json
```

Merge the `hooks` object into your existing settings. You can also run `claude config edit` from Claude Code.

## Available Hooks

### 1. QMD Re-index (`Stop` hook)

**When**: After every Claude response completes (the `Stop` event).
**What**: Runs `qmd embed` to incrementally update the search index with any notes that were created or modified during the agent's turn.
**Why**: Keeps the QMD semantic search index fresh without blocking individual file edits. QMD only re-embeds changed files, so this is fast for typical interactions.

- Silently no-ops if QMD is not installed
- 120-second timeout (generous for large batch operations)
- Shows "Updating QMD search index..." in the Claude Code status line

**Requires**: QMD installed (`npm install -g @tobilu/qmd`) with collections configured for your vaults.

### 2. Update Modified Timestamp (`PostToolUse` hook)

**When**: After Claude edits or writes any `.md` file in the vault.
**What**: Runs `update-modified.py` to set the `modified` frontmatter field to the current timestamp.
**Why**: Keeps the `modified` field accurate without Claude needing to remember to do it manually every time.

- Only triggers on `.md` files in vault paths (matches `*obsidian-vaults*`)
- Skips template files (`_templates/`)

### 3. Auto-link Daily Note (`PostToolUse` hook)

**When**: After Claude creates a new `.md` file in the vault.
**What**: Runs `link-to-daily.py` to append a `[[wikilink]]` to the new note under the "Notes Created Today" section of today's daily note.
**Why**: The daily note is the hub — everything created that day should be discoverable from it.

- Only triggers on `Write` (new files), not `Edit`
- Skips daily notes themselves and templates
- Only adds the link if today's daily note already exists (won't create one)
- Checks for duplicates before adding

### 4. Frontmatter Reminder (`PreToolUse` hook)

**When**: Before Claude edits or writes any `.md` file in the vault.
**What**: Prints a reminder to update the `modified` field in frontmatter.
**Why**: Belt-and-suspenders — reminds the agent even though the PostToolUse hook also handles it automatically.

## Hook Scripts

| Script | Purpose |
|--------|---------|
| `update-modified.py` | Updates `modified` frontmatter field to current timestamp |
| `link-to-daily.py` | Appends `[[wikilink]]` to today's daily note |
| `validate-frontmatter.py` | Validates frontmatter schemas (used manually or in CI) |

## Configuration Reference

See `hook-configs.json` for the complete configuration. The hooks use these Claude Code event types:

| Event | Fires When | Used For |
|-------|-----------|----------|
| `Stop` | Agent finishes full response | QMD re-indexing |
| `PostToolUse` | After a tool call succeeds | Timestamp updates, daily note linking |
| `PreToolUse` | Before a tool call executes | Frontmatter reminders |

## Customization

To adjust vault path matching, edit the `*obsidian-vaults*` glob in each hook command to match your actual vault locations. For example, if your vaults are at `~/notes/work` and `~/notes/personal`, change to `*notes*`.
