
.PHONY: sync-chart-app-version check-chart-app-version aws-credentials

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

aws-credentials:
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_PROFILE
	eval "$(aws configure export-credentials --format env)"


