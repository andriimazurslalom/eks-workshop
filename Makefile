AWS_PROFILE ?= playground

.PHONY: sync-chart-app-version check-chart-app-version aws-credentials release-patch release-minor tag-release install-git-hooks release-notes publish-release-tag release-publish-tag

install-git-hooks:
	git config core.hooksPath .githooks
	chmod +x .githooks/commit-msg
	chmod +x scripts/lint_commit_msg.py


sync-chart-app-version:
	@APP_VERSION=$$(grep '^version' apps/sample_app/pyproject.toml | head -1 | sed -E 's/version\s*=\s*"([^"]+)".*/\1/'); \
	sed -i "s/^appVersion:.*/appVersion: \"$$APP_VERSION\"/" charts/sample-app/Chart.yaml; \
	echo "Updated charts/sample-app/Chart.yaml appVersion to $$APP_VERSION"

check-chart-app-version:
	@APP_VERSION=$$(grep '^version' apps/sample_app/pyproject.toml | head -1 | sed -E 's/version\s*=\s*"([^"]+)".*/\1/'); \
	CHART_APP_VERSION=$$(grep '^appVersion:' charts/sample-app/Chart.yaml | sed -E 's/appVersion:\s*"?([^"]+)"?.*/\1/'); \
	if [ "$$APP_VERSION" != "$$CHART_APP_VERSION" ]; then \
		echo "Chart appVersion drift detected: pyproject.toml=$$APP_VERSION, Chart.yaml=$$CHART_APP_VERSION"; \
		echo "Run: make sync-chart-app-version"; \
		exit 1; \
	fi; \
	echo "Chart appVersion matches pyproject version: $$APP_VERSION"

release-patch:
	@NEW_VERSION=$$(python3 -c 'from pathlib import Path; import re; p = Path("apps/sample_app/pyproject.toml"); text = p.read_text(); m = re.search(r"^version = \"(\d+)\.(\d+)\.(\d+)\"$$", text, re.M); assert m, "Could not find SemVer version in apps/sample_app/pyproject.toml"; major, minor, patch = map(int, m.groups()); new_version = f"{major}.{minor}.{patch + 1}"; updated = re.sub(r"^version = \"\d+\.\d+\.\d+\"$$", f"version = \"{new_version}\"", text, count=1, flags=re.M); p.write_text(updated); print(new_version)'); \
	echo "Bumped app version to $$NEW_VERSION"; \
	$(MAKE) sync-chart-app-version; \
	$(MAKE) check-chart-app-version

release-minor:
	@NEW_VERSION=$$(python3 -c 'from pathlib import Path; import re; p = Path("apps/sample_app/pyproject.toml"); text = p.read_text(); m = re.search(r"^version = \"(\d+)\.(\d+)\.(\d+)\"$$", text, re.M); assert m, "Could not find SemVer version in apps/sample_app/pyproject.toml"; major, minor, patch = map(int, m.groups()); new_version = f"{major}.{minor + 1}.0"; updated = re.sub(r"^version = \"\d+\.\d+\.\d+\"$$", f"version = \"{new_version}\"", text, count=1, flags=re.M); p.write_text(updated); print(new_version)'); \
	echo "Bumped app version to $$NEW_VERSION"; \
	$(MAKE) sync-chart-app-version; \
	$(MAKE) check-chart-app-version

aws-credentials:
	@echo 'Run this in your shell, not through make:'
	@echo '  eval "$$(aws configure export-credentials --profile ${AWS_PROFILE} --format env)"'

tag-release:
	@VERSION=$$(python3 -c 'from pathlib import Path; import re; text = Path("apps/sample_app/pyproject.toml").read_text(); m = re.search(r"^version = \"(\d+\.\d+\.\d+)\"$$", text, re.M); assert m, "Could not find SemVer version in apps/sample_app/pyproject.toml"; print(m.group(1))'); \
	TAG="v$$VERSION"; \
	if ! git diff --quiet || ! git diff --cached --quiet; then \
		echo "Working tree is dirty. Commit or stash changes before tagging."; \
		exit 1; \
	fi; \
	if git rev-parse "$$TAG" >/dev/null 2>&1; then \
		echo "Tag $$TAG already exists."; \
		exit 1; \
	fi; \
	git tag -a "$$TAG" -m "Release $$TAG"; \
	echo "Created annotated tag $$TAG"

publish-release-tag:
	@VERSION=$$(python3 -c 'from pathlib import Path; import re; text = Path("apps/sample_app/pyproject.toml").read_text(); m = re.search(r"^version = \"(\d+\.\d+\.\d+)\"$$", text, re.M); assert m, "Could not find SemVer version in apps/sample_app/pyproject.toml"; print(m.group(1))'); \
	TAG="v$$VERSION"; \
	if ! git rev-parse "$$TAG" >/dev/null 2>&1; then \
		echo "Tag $$TAG does not exist locally. Run: make tag-release"; \
		exit 1; \
	fi; \
	git push origin "$$TAG"; \
	echo "Pushed tag $$TAG to origin"

release-publish-tag: tag-release publish-release-tag

release-notes:
	python3 scripts/generate_release_notes.py
