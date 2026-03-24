#!/usr/bin/env python3
"""
link-to-daily.py — Add a link to a newly created note in today's daily note.

Used as a Claude Code PostToolUse hook. When a new note is created in the vault,
this script appends a link to it under the "Notes Created Today" section of the
current daily note.

Usage:
    python link-to-daily.py /path/to/new-note.md
"""

import sys
import re
from datetime import datetime
from pathlib import Path


def find_vault_root(note_path: Path) -> Path | None:
    """Walk up from the note to find the vault root (contains .obsidian or CLAUDE.md)."""
    current = note_path.parent
    for _ in range(10):  # Max 10 levels up
        if (current / ".obsidian").exists() or (current / "CLAUDE.md").exists():
            return current
        if current == current.parent:
            break
        current = current.parent
    return None


def link_to_daily(filepath: str):
    path = Path(filepath).resolve()
    if not path.exists() or path.suffix != ".md":
        return

    vault_root = find_vault_root(path)
    if not vault_root:
        return

    today = datetime.now()
    daily_dir = vault_root / "01-daily" / str(today.year) / f"{today.month:02d}"
    daily_file = daily_dir / f"{today.strftime('%Y-%m-%d')}.md"

    if not daily_file.exists():
        return  # Don't create daily notes automatically from a hook

    note_name = path.stem
    link = f"- [[{note_name}]]"

    content = daily_file.read_text(encoding="utf-8")

    # Check if already linked
    if f"[[{note_name}]]" in content:
        return

    # Try to add under "Notes Created Today" section
    section_pattern = r'(## Notes Created Today\n)'
    match = re.search(section_pattern, content)

    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + link + "\n" + content[insert_pos:]
    else:
        # Append to end
        content = content.rstrip() + f"\n\n## Notes Created Today\n{link}\n"

    daily_file.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        link_to_daily(sys.argv[1])
