#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

PYPROJECT = Path("apps/sample_app/pyproject.toml")
OUTPUT_DIR = Path("releases")

TYPE_TITLES = {
    "feat": "Features",
    "fix": "Fixes",
    "docs": "Documentation",
    "refactor": "Refactors",
    "test": "Tests",
    "chore": "Chores",
}

COMMIT_RE = re.compile(r"^(?P<type>[a-z]+)(\([^)]+\))?(!)?: (?P<desc>.+)$")


def run_git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        check=True,
        text=True,
        capture_output=True,
    )
    return result.stdout.strip()


def get_current_version() -> str:
    text = PYPROJECT.read_text(encoding="utf-8")
    match = re.search(r'^version = "(\d+\.\d+\.\d+)"$', text, re.MULTILINE)
    if not match:
        raise SystemExit("Could not find version in apps/sample_app/pyproject.toml")
    return match.group(1)


def get_all_tags() -> list[str]:
    output = run_git("tag", "--sort=version:refname")
    return [line.strip() for line in output.splitlines() if line.strip()]


def get_previous_tag(current_tag: str) -> str | None:
    tags = get_all_tags()
    if current_tag not in tags:
        return None
    idx = tags.index(current_tag)
    if idx == 0:
        return None
    return tags[idx - 1]


def get_commit_subjects(revision_range: str) -> list[str]:
    output = run_git("log", "--pretty=format:%s", revision_range)
    return [line.strip() for line in output.splitlines() if line.strip()]


def classify_commits(subjects: list[str]) -> tuple[dict[str, list[str]], list[str]]:
    grouped: dict[str, list[str]] = defaultdict(list)
    uncategorized: list[str] = []

    for subject in subjects:
        match = COMMIT_RE.match(subject)
        if not match:
            uncategorized.append(subject)
            continue

        commit_type = match.group("type")
        grouped[commit_type].append(subject)

    return grouped, uncategorized


def build_markdown(version: str, previous_tag: str | None, current_tag: str, grouped: dict[str, list[str]], uncategorized: list[str]) -> str:
    lines: list[str] = []
    lines.append(f"# Release {current_tag}")
    lines.append("")

    if previous_tag:
        lines.append(f"Changes since `{previous_tag}`.")
    else:
        lines.append("Initial tagged release.")
    lines.append("")

    ordered_types = ["feat", "fix", "docs", "refactor", "test", "chore"]
    for commit_type in ordered_types:
        commits = grouped.get(commit_type, [])
        if not commits:
            continue

        lines.append(f"## {TYPE_TITLES.get(commit_type, commit_type.title())}")
        lines.append("")
        for subject in commits:
            lines.append(f"- {subject}")
        lines.append("")

    if uncategorized:
        lines.append("## Other")
        lines.append("")
        for subject in uncategorized:
            lines.append(f"- {subject}")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    version = get_current_version()
    current_tag = f"v{version}"

    tags = get_all_tags()
    if current_tag not in tags:
        raise SystemExit(f"Current tag {current_tag} does not exist. Create it before generating release notes.")

    previous_tag = get_previous_tag(current_tag)

    revision_range = current_tag if previous_tag is None else f"{previous_tag}..{current_tag}"
    subjects = get_commit_subjects(revision_range)
    grouped, uncategorized = classify_commits(subjects)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / f"{current_tag}.md"
    output_path.write_text(
        build_markdown(version, previous_tag, current_tag, grouped, uncategorized),
        encoding="utf-8",
    )

    print(f"Wrote release notes to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
