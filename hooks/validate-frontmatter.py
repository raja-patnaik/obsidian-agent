#!/usr/bin/env python3
"""
validate-frontmatter.py — Validate frontmatter of staged markdown files before commit.

Used as a Claude Code PreToolUse hook or git pre-commit hook.
Checks that all .md files in the vault have valid frontmatter with required fields.

Usage:
    python validate-frontmatter.py /path/to/vault
    python validate-frontmatter.py /path/to/specific-file.md
"""

import sys
import yaml
from pathlib import Path
from datetime import datetime

VALID_TYPES = {
    "daily", "meeting", "project", "area", "resource",
    "person", "idea", "decision", "standup", "journal", "list"
}

REQUIRED_FIELDS = {
    "__all__": ["type", "created", "modified", "tags"],
    "meeting": ["attendees", "status"],
    "project": ["status", "priority"],
    "person": ["relationship"],
    "idea": ["status"],
    "decision": ["status", "impact"],
}

VALID_STATUSES = {
    "meeting": {"upcoming", "in-progress", "completed", "cancelled"},
    "project": {"active", "on-hold", "completed", "cancelled"},
    "idea": {"seed", "exploring", "developing", "parked", "executed"},
    "decision": {"proposed", "accepted", "deprecated", "superseded"},
    "resource": {"unread", "reading", "read", "reference"},
}

VALID_PRIORITIES = {"p0", "p1", "p2", "p3"}


def parse_frontmatter(filepath: Path) -> tuple[dict | None, list[str]]:
    """Parse frontmatter and return (data, errors)."""
    errors = []

    try:
        content = filepath.read_text(encoding="utf-8")
    except Exception as e:
        return None, [f"Cannot read file: {e}"]

    if not content.startswith("---"):
        return None, ["Missing frontmatter (file doesn't start with ---)"]

    end = content.find("---", 3)
    if end == -1:
        return None, ["Malformed frontmatter (no closing ---)"]

    try:
        fm = yaml.safe_load(content[3:end])
    except yaml.YAMLError as e:
        return None, [f"Invalid YAML in frontmatter: {e}"]

    if not isinstance(fm, dict):
        return None, ["Frontmatter is not a valid YAML mapping"]

    return fm, errors


def validate_note(filepath: Path) -> list[str]:
    """Validate a single note file. Returns list of error messages."""
    errors = []

    fm, parse_errors = parse_frontmatter(filepath)
    errors.extend(parse_errors)

    if fm is None:
        return errors

    # Check universal required fields
    for field in REQUIRED_FIELDS["__all__"]:
        if field not in fm:
            errors.append(f"Missing required field: {field}")

    # Check type is valid
    note_type = fm.get("type", "")
    if note_type and note_type not in VALID_TYPES:
        errors.append(f"Invalid type: '{note_type}'. Must be one of: {', '.join(sorted(VALID_TYPES))}")

    # Check type-specific required fields
    if note_type in REQUIRED_FIELDS:
        for field in REQUIRED_FIELDS[note_type]:
            if field not in fm:
                errors.append(f"Missing required field for {note_type}: {field}")

    # Validate tags is a list
    tags = fm.get("tags")
    if tags is not None and not isinstance(tags, list):
        errors.append("'tags' must be a YAML list, not a string")

    # Validate status values
    if note_type in VALID_STATUSES:
        status = fm.get("status", "")
        if status and status not in VALID_STATUSES[note_type]:
            errors.append(
                f"Invalid status '{status}' for {note_type}. "
                f"Must be one of: {', '.join(sorted(VALID_STATUSES[note_type]))}"
            )

    # Validate priority for projects
    if note_type == "project":
        priority = fm.get("priority", "")
        if priority and priority not in VALID_PRIORITIES:
            errors.append(f"Invalid priority '{priority}'. Must be one of: {', '.join(sorted(VALID_PRIORITIES))}")

    # Validate dates
    for date_field in ["created", "modified"]:
        val = fm.get(date_field)
        if val and isinstance(val, str):
            try:
                datetime.fromisoformat(val)
            except ValueError:
                errors.append(f"Invalid date format for {date_field}: '{val}' (use YYYY-MM-DDTHH:MM)")

    return errors


def validate_path(target: Path) -> int:
    """Validate a file or all .md files in a directory. Returns error count."""
    total_errors = 0

    if target.is_file():
        files = [target]
    else:
        files = sorted(target.rglob("*.md"))
        # Filter out templates, obsidian config, attachments
        files = [
            f for f in files
            if not any(part.startswith(".") or part == "_templates" or part == "_attachments"
                       for part in f.relative_to(target).parts)
        ]

    for filepath in files:
        errors = validate_note(filepath)
        if errors:
            rel_path = filepath.relative_to(target) if target.is_dir() else filepath.name
            print(f"\n❌ {rel_path}")
            for err in errors:
                print(f"   • {err}")
                total_errors += 1

    if total_errors == 0:
        print("✅ All notes have valid frontmatter")
    else:
        print(f"\n{total_errors} error(s) found across {len(files)} file(s)")

    return total_errors


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate-frontmatter.py /path/to/vault/or/file.md")
        sys.exit(1)

    target = Path(sys.argv[1]).resolve()
    if not target.exists():
        print(f"Error: {target} does not exist")
        sys.exit(1)

    error_count = validate_path(target)
    sys.exit(1 if error_count > 0 else 0)
