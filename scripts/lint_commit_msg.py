#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ALLOWED_TYPES = {"feat", "fix", "docs", "refactor", "test", "chore"}

COMMIT_RE = re.compile(
    r"^(?P<type>[a-z]+)(\([a-z0-9._/-]+\))?(!)?: (?P<description>.+)$"
)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: lint_commit_msg.py <commit-message-file>", file=sys.stderr)
        return 2

    msg_path = Path(sys.argv[1])
    lines = msg_path.read_text(encoding="utf-8").splitlines()

    if not lines:
        print("Commit message is empty.", file=sys.stderr)
        return 1

    subject = lines[0].strip()

    match = COMMIT_RE.match(subject)
    if not match:
        print(
            "Invalid commit message format.\n"
            "Expected: <type>[optional-scope][!]: <description>\n"
            "Example: feat(logging): add fluent bit cloudwatch output",
            file=sys.stderr,
        )
        return 1

    commit_type = match.group("type")
    description = match.group("description")

    if commit_type not in ALLOWED_TYPES:
        print(
            f"Invalid commit type '{commit_type}'. "
            f"Allowed types: {', '.join(sorted(ALLOWED_TYPES))}",
            file=sys.stderr,
        )
        return 1

    if len(subject) > 72:
        print(
            f"Commit subject is too long ({len(subject)} chars). Keep it at 72 or less.",
            file=sys.stderr,
        )
        return 1

    if description[0].isupper():
        print(
            "Commit description should start with a lowercase letter.", file=sys.stderr
        )
        return 1

    if subject.endswith("."):
        print("Commit subject must not end with a period.", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
