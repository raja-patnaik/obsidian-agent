#!/usr/bin/env python3
"""
update-modified.py — Update the 'modified' field in a markdown file's frontmatter.

Used as a Claude Code PostToolUse hook to keep timestamps current.

Usage:
    python update-modified.py /path/to/note.md
"""

import sys
import re
from datetime import datetime
from pathlib import Path


def update_modified(filepath: str):
    path = Path(filepath)
    if not path.exists() or path.suffix != ".md":
        return

    content = path.read_text(encoding="utf-8")

    # Check if file has frontmatter
    if not content.startswith("---"):
        return

    end = content.find("---", 3)
    if end == -1:
        return

    frontmatter = content[3:end]
    body = content[end:]

    now = datetime.now().strftime("%Y-%m-%dT%H:%M")

    # Update or add modified field
    if re.search(r'^modified:', frontmatter, re.MULTILINE):
        frontmatter = re.sub(
            r'^modified:.*$',
            f'modified: {now}',
            frontmatter,
            flags=re.MULTILINE
        )
    else:
        frontmatter = frontmatter.rstrip() + f"\nmodified: {now}\n"

    path.write_text(f"---{frontmatter}{body}", encoding="utf-8")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        update_modified(sys.argv[1])
