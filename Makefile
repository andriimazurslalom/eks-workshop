
.PHONY: sync-chart-app-version check-chart-app-version aws-credentials release-patch release-minor

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
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_PROFILE
	eval "$(aws configure export-credentials --format env)"


