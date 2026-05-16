# TODO: Host `sample_app` on EKS

This checklist is now ordered to teach the overall application deployment flow first, then the deeper Kubernetes and AWS details afterward.

The goal is to make it easy to answer:

1. How does a team take backend code and get it running on an existing EKS cluster?
2. What do I need to know first to deploy applications soon?
3. What topics can I safely postpone until after I understand the main flow?

## 1. Understand the end-to-end deployment flow first

This is the core dev flow for shipping a backend to EKS:

- [x] Understand that the app must be containerized first
- [x] Understand that the image must be pushed to a registry such as ECR
- [x] Understand that Kubernetes manifests describe how the app runs on EKS
- [x] Understand that configuration and secrets are injected at deploy time
- [x] Understand that the app is deployed with `kubectl apply` or `kubectl apply -k`
- [x] Understand that verification happens with `kubectl`, logs, and HTTP checks
- [x] Understand that updates happen by pushing a new image and updating the Deployment
- [x] Understand that rollback happens through Deployment revision history

## 2. Prepare and package the application

- [x] Add a `Dockerfile` for `apps/sample_app`
- [x] Make sure the app listens on a configurable host and port
- [x] Confirm there is a health endpoint suitable for Kubernetes probes
- [x] Add a `.dockerignore`
- [x] Build the Docker image locally
- [x] Run the container locally
- [x] Verify the app responds on `/`
- [x] Verify the app responds on `/health`
- [x] Verify the app responds on `/whoami`

## 3. Publish the image to AWS

- [x] Create an Amazon ECR repository for `sample_app`
- [x] Authenticate Docker to ECR
- [x] Tag the Docker image for ECR
- [x] Push the image to ECR
- [x] Use versioned image tags for deployments

## 4. Deploy the application to the existing EKS cluster

- [x] Create a `k8s/sample_app/` folder in the repo root
- [x] Create a namespace manifest for the application
- [x] Create a `Deployment` manifest
- [x] Set the container image to the ECR image
- [x] Set the container port
- [x] Add readiness and liveness probes
- [x] Add resource requests and limits
- [x] Create a `Service` manifest
- [x] Connect `kubectl` to the EKS cluster for the application workflow
- [x] Apply the namespace manifest
- [x] Apply the `Deployment`
- [x] Apply the `Service`
- [x] Wait for the Pods to become `Running`

## 5. Configure the app the way real teams do

- [x] Identify required environment variables
- [x] Put non-secret config directly in the `Deployment` first
- [x] Move non-secret config to a `ConfigMap` once there are multiple settings
- [x] Store secrets in a `Secret` when the app starts using sensitive values
- [x] Reference config and secrets from the `Deployment`
- [x] Add a safe `/config` style endpoint for runtime verification

## 6. Verify and debug a deployment

- [x] Check `kubectl get pods -n sample-app`
- [x] Check `kubectl get svc -n sample-app`
- [x] Check `kubectl logs` for the app Pod
- [x] Port-forward the service locally
- [x] Test `/`
- [x] Test `/health`
- [x] Test `/whoami`
- [x] Test `/config`
- [x] Use `kubectl describe`, `kubectl logs`, and `kubectl exec` for debugging
- [x] Inspect Pod events when something fails to start
- [x] Read EKS worker node and Pod scheduling behavior

## 7. Learn how application changes are delivered safely

- [x] Perform the first rolling update from `0.2.0` to `0.2.1` and verify it with `/whoami` and `/config`
- [x] Learn how rolling updates work by deploying a new image version
- [x] Learn how to roll back to an earlier image tag
- [x] Learn how to scale the `Deployment` manually
- [x] Increase replicas from `1` when needed
- [x] Add a PodDisruptionBudget later
- [x] Add autoscaling later if traffic requires it

## 8. Expose the app and understand service entrypoints

- [x] Start with `Service` type `ClusterIP` to learn internal networking first
- [x] Decide between `LoadBalancer` and `Ingress`
- [x] If using `LoadBalancer`, expose the service publicly
- [x] Learn the difference between `ClusterIP`, `NodePort`, `LoadBalancer`, and `Ingress`
- [x] Learn how an AWS load balancer is created from a Kubernetes `Service`
- [x] If using `Ingress`, install and configure an ingress controller
- [x] Verify ALB-backed Ingress routing works end-to-end
- [x] Return the backend Service to `ClusterIP` when using Ingress as the public entrypoint
- [ ] Add DNS and TLS later if needed

## 9. Add delivery tooling once the raw flow is clear

- [x] Add a repo-level or app-level `Makefile` target for Kubernetes deploys
- [x] Add a `kustomization.yaml` for the sample app
- [ ] Add a root `k8s/` README with deploy and debug commands
- [x] Add a basic `Helm` chart after the raw YAML deployment works
- [x] Learn `Kustomize` as an alternative to Helm for environment overlays
- [x] Add `values-dev.yaml` and `values-prod.yaml`
- [x] Understand Helm install, upgrade, history, and rollback at a practical level
- [x] Add unit tests to the CI pipeline before image build and deployment
- [x] Add image scanning in CI
- [x] Add CI/CD to build, push, and deploy automatically

## 10. Learn deeper Kubernetes behavior after the main flow

- [x] Learn how labels and selectors connect `Deployment`, `Pods`, and `Service`
- [x] Learn how in-cluster DNS works for `Service` discovery
- [x] Learn when to use `ConfigMap` vs `Secret`
- [x] Learn how resource requests and limits affect Pod scheduling
- [x] Learn how readiness and liveness probes affect traffic and restarts
- [x] Learn how namespaces help separate workloads
- [x] Understand how a `Service` routes to multiple replicas
- [x] Learn how a HorizontalPodAutoscaler works
- [x] Learn how a PodDisruptionBudget protects availability during voluntary disruptions
- [x] Create an operator runbook/checklist for monitoring and first-response debugging
- [x] Add monitoring and alerting tooling later

## 11. Learn AWS-specific platform topics later

- [x] Add AWS Load Balancer Controller when moving to ingress-based routing
- [x] Learn IRSA when Pods need AWS API access
- [x] Migrate application runtime secrets to AWS Secrets Manager and fetch them from Pods via IRSA
- [ ] Add `cert-manager` when learning TLS automation
- [ ] Add `external-dns` when learning DNS automation

## 12. Repo structure and documentation

- [x] Add a `Dockerfile` under `apps/sample_app`
- [x] Add a `k8s/` folder for Kubernetes manifests
- [x] Add a `charts/` folder for Helm packaging
- [x] Add an `hpa.yaml` template to the Helm chart
- [x] Add deployment documentation for the sample app

## 13. Learn release engineering and platform operations next
- [x] Add Python linting to CI with `ruff` or a similar tool
- [x] Add `helm lint` to the CI pipeline
- [x] Add `helm template` rendering checks to the CI pipeline
- [x] Add a post-deploy smoke test against the live application endpoint
- [x] Add secret scanning to the CI pipeline
- [x] Learn SemVer for application releases, image tags, and Helm charts
- [x] Distinguish Helm chart `version` from `appVersion`
- [x] Learn Conventional Commits and release automation workflows
- [x] Add manual release bump targets for patch and minor versions
- [x] Add annotated git release tags tied to app versions
- [x] Add commit message linting for Conventional Commits
- [ ] Evaluate adopting the `pre-commit` framework for local hook management
- [x] Generate changelog or release notes from commit history
- [ ] Evaluate fuller release automation tooling after the manual workflow is clear
- [x] Add centralized logging for the application and cluster
- [x] Learn Prometheus metrics collection for Kubernetes workloads
- [ ] Add Grafana dashboards for cluster and application visibility
- [x] Add alerting for application health and Kubernetes resource issues
- [ ] Learn GitOps with Argo CD or Flux after the imperative pipeline flow is clear
- [ ] Learn policy as code with Kyverno or OPA/Gatekeeper
- [ ] Learn Kubernetes `NetworkPolicy` and restrict east-west traffic intentionally
- [ ] Learn progressive delivery patterns such as canary or blue-green deployments
- [ ] Learn SBOM generation and artifact provenance basics
- [ ] Learn image signing and verification concepts
- [ ] Compare secrets delivery patterns such as IRSA runtime fetch, External Secrets Operator, and CSI-based mounts
- [ ] Learn cluster autoscaling beyond HPA, including node-level scaling behavior
- [ ] Learn backup and disaster recovery patterns for Kubernetes workloads
- [ ] Learn multi-environment promotion workflows across dev, stage, and prod
