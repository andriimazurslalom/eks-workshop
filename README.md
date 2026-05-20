# EKS Workshop

This repository is a hands-on learning project for deploying and operating a backend application on Amazon EKS.

It started as a small FastAPI app and evolved into a more realistic platform exercise covering:

- containerization with Docker
- image publishing to ECR
- raw Kubernetes manifests
- Kustomize overlays
- Helm packaging
- ConfigMap and Secret usage
- IRSA for Pods
- AWS Load Balancer Controller and ALB-backed Ingress
- HPA and PDB
- CI/CD with CodePipeline and CodeBuild

The main goal is to answer a practical question:

- how does a team take backend code and get it running safely on an existing EKS cluster?

## Repo layout

- [apps/sample_app](apps/sample_app) contains the FastAPI application, Dockerfile, and local build helpers
- [k8s/sample_app](k8s/sample_app) contains raw Kubernetes manifests used early in the learning path
- [charts/sample-app](charts/sample-app) contains the Helm chart used for the more complete deployment workflow
- [infra](infra) contains Terraform for the VPC and EKS cluster
- [TODO_EKS_SAMPLE_APP.md](TODO_EKS_SAMPLE_APP.md) tracks the learning path and completed topics
- [RUNBOOK_SAMPLE_APP_EKS.md](RUNBOOK_SAMPLE_APP_EKS.md) is the operational runbook for the app on EKS

## Commit style:

This repo uses Conventional Commits for local commit linting.

Allowed commit types:
- feat: new capability
- fix: bug fix
- docs: documentation-only change
- refactor: code cleanup without behavior change
- test: test-only change
- chore: tooling/config/maintenance

Install hooks with:

```bash
make install-git-hooks
```

## Release Flow

1. `make release-patch` or `make release-minor`
2. commit the version bump
3. `make publish-release-tag`
4. `make release-notes`


## Release Automation

This repo uses Conventional Commits and Release Please for release automation.

Release Please watches commits merged into `main`, opens a release PR with the next version bump and changelog updates, and creates the Git tag and GitHub release after that PR is merged.


## How the repo evolved

The repo did not start with the full platform shape.

It evolved in roughly this order:

1. build a simple app and containerize it
2. push the image to ECR
3. deploy with raw YAML using `kubectl`
4. add config, secrets, probes, and resource limits
5. learn Kustomize for image and environment overrides
6. move to Helm for packaging, upgrades, rollback, and values files
7. expose the app with AWS load balancers, then move to ALB-backed Ingress
8. add autoscaling and disruption protection
9. migrate runtime secret access to AWS Secrets Manager through IRSA
10. automate build and deploy with CodePipeline and CodeBuild

That progression is intentional. The repo keeps both the earlier and later approaches so the learning path stays visible.

## Current architecture

At the current stage, the app is intended to run with:

- Docker image stored in ECR
- Terraform-managed VPC and EKS cluster
- Helm-managed application deployment
- `ClusterIP` Service behind ALB-backed Ingress
- runtime secret names passed to the Pod, with secret values fetched from AWS Secrets Manager via IRSA
- CI/CD handled by CodePipeline and CodeBuild

## Key docs

- [TODO_EKS_SAMPLE_APP.md](TODO_EKS_SAMPLE_APP.md) shows what has been covered and what remains
- [RUNBOOK_SAMPLE_APP_EKS.md](RUNBOOK_SAMPLE_APP_EKS.md) explains how to check health, rollout status, scaling, and ingress behavior

## How to repeat this experiment

If you want to run a similar learning exercise from scratch, the easiest approach is:

1. create a new empty project folder
2. copy [TODO_EKS_SAMPLE_APP.md](TODO_EKS_SAMPLE_APP.md) into that folder
3. add a small backend app or another minimal service you want to deploy
4. start a new Codex session in that folder
5. use the checklist as the step-by-step learning plan

The important idea is:

- do not start with every platform feature at once
- begin with containerization, image publishing, and a basic deployment
- then layer in config, secrets, ingress, scaling, IRSA, and CI/CD

This repo followed that progression deliberately, and the checklist is meant to be reusable.

If you use Codex for the exercise, a good starting prompt is:

```text
I want to learn how to deploy a backend app to EKS step by step. Use TODO_EKS_SAMPLE_APP.md as the learning path, help me implement each stage in this repo, and explain the reasoning as we go.
```

That gives you:

- a concrete technical goal
- a staged path through the topics
- a reusable record of what was completed and what remains

## Notes

- This repo is structured as a learning and reference project, not a polished production template
- Some defaults are intentionally generic so environment-specific values can be supplied from the local shell or CI/CD runner
- The history has been squashed and sanitized to keep the public version clean
