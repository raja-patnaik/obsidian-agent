#!/usr/bin/env bash
# setup-vault.sh — Bootstrap a new Obsidian vault with the Claude-integrated structure
#
# Usage:
#   ./setup-vault.sh /path/to/vault work    # Set up a work vault
#   ./setup-vault.sh /path/to/vault personal # Set up a personal vault
#
# This script:
#   1. Creates the standard folder structure
#   2. Copies templates
#   3. Places the CLAUDE.md file
#   4. Creates today's daily note
#   5. Creates a .gitignore for the vault

set -euo pipefail

VAULT_PATH="${1:?Usage: $0 /path/to/vault [work|personal]}"
VAULT_TYPE="${2:-work}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPT_DIR")"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY_NAME=$(date +%A)
NOW=$(date +%Y-%m-%dT%H:%M)

echo "======================================"
echo "Obsidian Vault Setup"
echo "Path: $VAULT_PATH"
echo "Type: $VAULT_TYPE"
echo "======================================"
echo ""

# --- Create folder structure ---
echo "Creating folder structure..."

# Core folders (both vaults)
mkdir -p "$VAULT_PATH"/{00-inbox,01-daily/$YEAR/$MONTH,02-projects,03-areas,04-resources/{articles,bookmarks,how-tos},05-people,06-meetings/$YEAR/$MONTH,07-ideas,08-archive,_templates,_attachments}

# Type-specific folders
if [ "$VAULT_TYPE" = "work" ]; then
    mkdir -p "$VAULT_PATH"/03-areas/{team,processes,goals}
    mkdir -p "$VAULT_PATH"/{09-decisions,10-standups}
    echo "  Created work-specific folders (decisions, standups)"
elif [ "$VAULT_TYPE" = "personal" ]; then
    mkdir -p "$VAULT_PATH"/03-areas/{health,finance,learning,home}
    mkdir -p "$VAULT_PATH"/{09-journal,10-lists}
    echo "  Created personal-specific folders (journal, lists)"
fi

echo "  Folder structure created."
echo ""

# --- Copy CLAUDE.md ---
echo "Installing CLAUDE.md..."
if [ "$VAULT_TYPE" = "work" ]; then
    cp "$SYSTEM_DIR/templates/work/CLAUDE.md" "$VAULT_PATH/CLAUDE.md"
else
    cp "$SYSTEM_DIR/templates/personal/CLAUDE.md" "$VAULT_PATH/CLAUDE.md"
fi

# Update the vault path in CLAUDE.md
sed -i "s|(update with actual path)|$VAULT_PATH|g" "$VAULT_PATH/CLAUDE.md" 2>/dev/null || true
echo "  CLAUDE.md installed."
echo ""

# --- Create today's daily note ---
echo "Creating today's daily note..."
DAILY_FILE="$VAULT_PATH/01-daily/$YEAR/$MONTH/$TODAY.md"
if [ ! -f "$DAILY_FILE" ]; then
    cat > "$DAILY_FILE" << EOF
---
type: daily
created: $NOW
modified: $NOW
tags: [daily]
energy:
mood:
vault: $VAULT_TYPE
---

# $TODAY $DAY_NAME

## Morning Intentions
- [ ]
- [ ]
- [ ]

## Log


## Notes Created Today


## End of Day Reflection


## Gratitude
-
EOF
    echo "  Created: $DAILY_FILE"
else
    echo "  Daily note already exists."
fi
echo ""

# --- Create .gitignore ---
echo "Creating .gitignore..."
cat > "$VAULT_PATH/.gitignore" << 'EOF'
# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/graph.json
.trash/

# System
.DS_Store
Thumbs.db

# Vault health reports (generated)
.vault-health-report.md
EOF
echo "  .gitignore created."
echo ""

# --- Create .obsidian config if it doesn't exist ---
if [ ! -d "$VAULT_PATH/.obsidian" ]; then
    echo "Creating minimal .obsidian config..."
    mkdir -p "$VAULT_PATH/.obsidian"
    cat > "$VAULT_PATH/.obsidian/app.json" << 'EOF'
{
  "attachmentFolderPath": "_attachments",
  "newFileLocation": "folder",
  "newFileFolderPath": "00-inbox",
  "showUnsupportedFiles": false,
  "alwaysUpdateLinks": true
}
EOF
    echo "  Obsidian config created (attachments → _attachments, new files → inbox)"
fi
echo ""

# --- Summary ---
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Install Kepano's official Obsidian skills plugin for Claude Code:"
echo "       /plugin marketplace add kepano/obsidian-skills"
echo "       /plugin install obsidian@obsidian-skills"
echo "  2. Install QMD and index this vault:"
echo "       npm install -g @tobilu/qmd"
echo "       qmd collection add $VAULT_PATH --name $VAULT_TYPE"
echo "       qmd context add $VAULT_TYPE \"$([ "$VAULT_TYPE" = "work" ] && echo "Work vault: projects, meetings, decisions, standups, people, ideas, resources" || echo "Personal vault: journal, health, finance, learning, ideas, lists, people")\""
echo "       qmd embed"
echo "  3. Open this folder as a vault in Obsidian"
echo "  4. Install recommended Obsidian community plugins (see docs/plugin-guide.md)"
echo "  5. Configure Claude Code hooks (see hooks/hook-configs.json)"
echo "  6. Start taking notes!"
echo ""
echo "To migrate existing notes:"
echo "  See docs/vault-migration-guide.md"
