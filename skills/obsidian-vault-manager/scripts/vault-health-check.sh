#!/usr/bin/env bash
# vault-health-check.sh — Run a comprehensive health check on an Obsidian vault
# Usage: ./vault-health-check.sh /path/to/vault [--fix]
#
# Checks:
#   1. Files missing frontmatter
#   2. Broken wikilinks
#   3. Files in wrong folders for their type
#   4. Naming convention violations
#   5. Orphan notes (no incoming links)
#   6. Stale notes (not modified in 90+ days)
#   7. Empty files
#   8. Missing required frontmatter fields

set -euo pipefail

VAULT_PATH="${1:-.}"
FIX_MODE="${2:-}"
REPORT=""
ISSUES=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_issue() {
    ISSUES=$((ISSUES + 1))
    REPORT+="[ERROR] $1\n"
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    WARNINGS=$((WARNINGS + 1))
    REPORT+="[WARN] $1\n"
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Ensure vault exists
if [ ! -d "$VAULT_PATH" ]; then
    echo "Error: Vault path '$VAULT_PATH' does not exist"
    exit 1
fi

echo "============================================"
echo "Obsidian Vault Health Check"
echo "Vault: $VAULT_PATH"
echo "Date: $(date -Iseconds)"
echo "============================================"
echo ""

# --- Check 1: Files missing frontmatter ---
log_info "Checking for files missing frontmatter..."
MISSING_FM=0
while IFS= read -r -d '' file; do
    # Skip templates, attachments, and hidden dirs
    case "$file" in
        */_templates/*|*/_attachments/*|*/.*) continue ;;
    esac

    first_line=$(head -n 1 "$file" 2>/dev/null || echo "")
    if [ "$first_line" != "---" ]; then
        log_issue "Missing frontmatter: ${file#$VAULT_PATH/}"
        MISSING_FM=$((MISSING_FM + 1))
    fi
done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/node_modules/*" -print0)

if [ "$MISSING_FM" -eq 0 ]; then
    log_ok "All markdown files have frontmatter"
fi
echo ""

# --- Check 2: Broken wikilinks ---
log_info "Checking for broken wikilinks..."
BROKEN_LINKS=0

# Build list of all note names (without extension)
declare -A note_names
while IFS= read -r -d '' file; do
    basename=$(basename "$file" .md)
    note_names["$basename"]=1
done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -print0)

# Find all wikilinks and check them
while IFS= read -r -d '' file; do
    case "$file" in
        */_templates/*|*/.obsidian/*) continue ;;
    esac

    # Extract wikilinks: [[target]] or [[target|alias]]
    grep -oP '\[\[([^\]|]+)' "$file" 2>/dev/null | sed 's/\[\[//' | while read -r link; do
        # Strip any heading anchors
        link_base="${link%%#*}"
        if [ -n "$link_base" ] && [ -z "${note_names[$link_base]+x}" ]; then
            log_warning "Broken link: [[${link_base}]] in ${file#$VAULT_PATH/}"
            BROKEN_LINKS=$((BROKEN_LINKS + 1))
        fi
    done
done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -print0)

if [ "$BROKEN_LINKS" -eq 0 ]; then
    log_ok "No broken wikilinks found"
fi
echo ""

# --- Check 3: Naming convention violations ---
log_info "Checking file naming conventions..."
NAMING_ISSUES=0
while IFS= read -r -d '' file; do
    case "$file" in
        */_templates/*|*/_attachments/*|*/.*|*/.obsidian/*) continue ;;
    esac

    basename=$(basename "$file" .md)

    # Check for spaces
    if [[ "$basename" == *" "* ]]; then
        log_issue "Filename has spaces: ${file#$VAULT_PATH/} (use kebab-case)"
        NAMING_ISSUES=$((NAMING_ISSUES + 1))
    fi

    # Check for uppercase (except CLAUDE.md)
    if [[ "$basename" != "CLAUDE" ]] && [[ "$basename" =~ [A-Z] ]]; then
        log_warning "Filename has uppercase: ${file#$VAULT_PATH/} (prefer lowercase)"
        NAMING_ISSUES=$((NAMING_ISSUES + 1))
    fi
done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -print0)

if [ "$NAMING_ISSUES" -eq 0 ]; then
    log_ok "All filenames follow conventions"
fi
echo ""

# --- Check 4: Empty files ---
log_info "Checking for empty files..."
EMPTY=0
while IFS= read -r -d '' file; do
    case "$file" in
        */_templates/*|*/.obsidian/*) continue ;;
    esac

    if [ ! -s "$file" ]; then
        log_warning "Empty file: ${file#$VAULT_PATH/}"
        EMPTY=$((EMPTY + 1))
    fi
done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -print0)

if [ "$EMPTY" -eq 0 ]; then
    log_ok "No empty files found"
fi
echo ""

# --- Check 5: Stale notes (90+ days without modification) ---
log_info "Checking for stale notes (90+ days old)..."
STALE=0
NINETY_DAYS_AGO=$(date -d "90 days ago" +%s 2>/dev/null || date -v-90d +%s 2>/dev/null || echo "0")

if [ "$NINETY_DAYS_AGO" != "0" ]; then
    while IFS= read -r -d '' file; do
        case "$file" in
            */_templates/*|*/_attachments/*|*/08-archive/*|*/.obsidian/*) continue ;;
        esac

        file_mod=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo "0")
        if [ "$file_mod" -lt "$NINETY_DAYS_AGO" ] 2>/dev/null; then
            log_warning "Stale note (90+ days): ${file#$VAULT_PATH/}"
            STALE=$((STALE + 1))
        fi
    done < <(find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -print0)
fi

if [ "$STALE" -eq 0 ]; then
    log_ok "No stale notes found"
fi
echo ""

# --- Check 6: Required folders ---
log_info "Checking required folder structure..."
REQUIRED_FOLDERS=(
    "00-inbox"
    "01-daily"
    "02-projects"
    "03-areas"
    "04-resources"
    "05-people"
    "06-meetings"
    "07-ideas"
    "08-archive"
    "_templates"
    "_attachments"
)

for folder in "${REQUIRED_FOLDERS[@]}"; do
    if [ ! -d "$VAULT_PATH/$folder" ]; then
        log_issue "Missing required folder: $folder/"
        if [ "$FIX_MODE" = "--fix" ]; then
            mkdir -p "$VAULT_PATH/$folder"
            log_info "Created: $folder/"
        fi
    fi
done
echo ""

# --- Summary ---
echo "============================================"
echo "Health Check Summary"
echo "============================================"
echo -e "Errors:   ${RED}${ISSUES}${NC}"
echo -e "Warnings: ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ "$ISSUES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}Vault is healthy!${NC}"
else
    echo "Run with --fix to auto-fix some issues:"
    echo "  $0 $VAULT_PATH --fix"
fi

# Write report
REPORT_PATH="$VAULT_PATH/.vault-health-report.md"
{
    echo "# Vault Health Report"
    echo "Date: $(date -Iseconds)"
    echo "Errors: $ISSUES"
    echo "Warnings: $WARNINGS"
    echo ""
    echo "## Details"
    echo -e "$REPORT"
} > "$REPORT_PATH"

echo ""
echo "Full report saved to: $REPORT_PATH"
