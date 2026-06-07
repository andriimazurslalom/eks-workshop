# Argo CD layout

This folder contains GitOps definitions for the EKS workshop.

## Objects

- `projects/sample-app.yaml`: Argo CD AppProject for the sample app
- `apps/sample-app-dev.yaml`: Argo CD Application for the dev deployment

## GitOps flow

1. CI builds and pushes a new image to ECR
2. A Git change updates `charts/sample-app/values-dev.yaml`
3. Argo CD detects the Git change
4. Argo CD syncs the Helm chart to the cluster

## Important rule

Do not deploy `sample-app` with `helm upgrade` from CI once Argo CD owns the application.
