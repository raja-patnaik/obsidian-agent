#!/usr/bin/env python3
"""
process-inbox.py — Process notes in the Obsidian vault inbox.

Reads all .md files from 00-inbox/, analyzes their frontmatter,
and moves them to the correct folder based on their `type` field.

Usage:
    python process-inbox.py /path/to/vault [--dry-run]
"""

import sys
import yaml
from datetime import datetime
from pathlib import Path


# Mapping of note types to their destination folders
TYPE_TO_FOLDER = {
    "daily": "01-daily",
    "project": "02-projects",
    "area": "03-areas",
    "resource": "04-resources",
    "person": "05-people",
    "meeting": "06-meetings",
    "idea": "07-ideas",
    "decision": "09-decisions",
    "standup": "10-standups",
    "journal": "09-journal",
    "list": "10-lists",
}

# Date-organized types get year/month subfolders
DATE_ORGANIZED_TYPES = {"daily", "meeting", "standup"}


def parse_frontmatter(filepath: Path) -> tuple[dict | None, str]:
    """Extract YAML frontmatter and body from a markdown file."""
    content = filepath.read_text(encoding="utf-8")

    if not content.startswith("---"):
        return None, content

    # Find closing ---
    end = content.find("---", 3)
    if end == -1:
        return None, content

    try:
        fm = yaml.safe_load(content[3:end])
        body = content[end + 3:].lstrip("\n")
        return fm, body
    except yaml.YAMLError:
        return None, content


def determine_destination(vault_path: Path, fm: dict, filename: str) -> Path:
    """Determine the correct destination folder for a note."""
    note_type = fm.get("type", "").lower()

    if note_type not in TYPE_TO_FOLDER:
        return vault_path / "00-inbox"  # Keep in inbox if type unknown

    base_folder = vault_path / TYPE_TO_FOLDER[note_type]

    # For date-organized types, create year/month subfolders
    if note_type in DATE_ORGANIZED_TYPES:
        created = fm.get("created", "")
        if created:
            try:
                if isinstance(created, str):
                    dt = datetime.fromisoformat(created)
                else:
                    dt = created
                base_folder = base_folder / str(dt.year) / f"{dt.month:02d}"
            except (ValueError, AttributeError):
                print(f"  ⚠ Could not parse 'created' date: {created!r} — skipping date subfolder")

    # Projects get their own subfolder
    if note_type == "project":
        project_name = Path(filename).stem
        base_folder = base_folder / project_name

    return base_folder


def add_missing_frontmatter(fm: dict, filename: str) -> dict:
    """Add any missing required frontmatter fields."""
    now = datetime.now().strftime("%Y-%m-%dT%H:%M")

    if "created" not in fm:
        fm["created"] = now
    if "modified" not in fm:
        fm["modified"] = now
    if "tags" not in fm:
        fm["tags"] = []

    # Ensure type tag is in tags list
    note_type = fm.get("type", "")
    if note_type and note_type not in fm["tags"]:
        fm["tags"].insert(0, note_type)

    return fm


def rebuild_file(fm: dict, body: str) -> str:
    """Reconstruct a markdown file from frontmatter and body."""
    yaml_str = yaml.dump(fm, default_flow_style=False, allow_unicode=True, sort_keys=False)
    return f"---\n{yaml_str}---\n\n{body}"


def process_inbox(vault_path: Path, dry_run: bool = False):
    """Process all files in the vault's inbox."""
    inbox = vault_path / "00-inbox"

    if not inbox.exists():
        print(f"No inbox found at {inbox}")
        return

    files = list(inbox.glob("*.md"))

    if not files:
        print("Inbox is empty. Nothing to process.")
        return

    print(f"Found {len(files)} file(s) in inbox.\n")

    moved = 0
    errors = 0

    for filepath in sorted(files):
        filename = filepath.name
        print(f"Processing: {filename}")

        fm, body = parse_frontmatter(filepath)

        if fm is None:
            print(f"  ⚠ No valid frontmatter — skipping (add frontmatter first)")
            errors += 1
            continue

        note_type = fm.get("type", "")
        if not note_type:
            print(f"  ⚠ No 'type' field in frontmatter — skipping")
            errors += 1
            continue

        if note_type not in TYPE_TO_FOLDER:
            print(f"  ⚠ Unknown type '{note_type}' — keeping in inbox")
            errors += 1
            continue

        # Fix up frontmatter
        fm = add_missing_frontmatter(fm, filename)
        fm["modified"] = datetime.now().strftime("%Y-%m-%dT%H:%M")

        # Determine destination
        dest_folder = determine_destination(vault_path, fm, filename)
        dest_path = dest_folder / filename

        print(f"  → Moving to: {dest_folder.relative_to(vault_path)}/")

        if not dry_run:
            dest_folder.mkdir(parents=True, exist_ok=True)

            # Write updated content, then verify before removing source
            updated_content = rebuild_file(fm, body)
            dest_path.write_text(updated_content, encoding="utf-8")

            if not dest_path.exists():
                print(f"  ✗ Failed to write {dest_path} — keeping original")
                errors += 1
                continue

            filepath.unlink()

        moved += 1

    print(f"\n{'[DRY RUN] ' if dry_run else ''}Results:")
    print(f"  Moved:  {moved}")
    print(f"  Errors: {errors}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process-inbox.py /path/to/vault [--dry-run]")
        sys.exit(1)

    vault = Path(sys.argv[1]).resolve()
    dry = "--dry-run" in sys.argv

    if not vault.is_dir():
        print(f"Error: {vault} is not a directory")
        sys.exit(1)

    process_inbox(vault, dry_run=dry)
