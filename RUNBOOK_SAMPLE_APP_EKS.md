# Runbook: Operating `sample-app` on EKS

This runbook is a practical operator checklist for running `sample-app` on the EKS cluster in this repository.

It is meant to answer:

- Is the app healthy?
- Is the app reachable?
- Are rollouts working?
- Is scaling working?
- Is Kubernetes protecting availability?
- What should I check first when something breaks?

## 1. Quick status check

Use these first when you want a fast overview.

```bash
kubectl get deployment -n sample-app
kubectl get pods -n sample-app -o wide
kubectl get svc -n sample-app
kubectl get hpa -n sample-app
kubectl get pdb -n sample-app
kubectl top pods -n sample-app
kubectl top nodes
```

Healthy signs:

- Deployment shows desired and ready replicas aligned
- Pods are `Running` and `Ready`
- Service exists and has an external hostname if using `LoadBalancer`
- HPA shows valid metrics
- PDB exists and allows disruptions according to policy
- Pod and node metrics are available

## 2. Application health checks

Test the application endpoints directly.

If using the public load balancer:

```bash
curl http://<load-balancer-hostname>/
curl http://<load-balancer-hostname>/health
curl http://<load-balancer-hostname>/whoami
curl http://<load-balancer-hostname>/config
```

If using port-forward:

```bash
kubectl port-forward -n sample-app svc/sample-app 8080:80
```

Then:

```bash
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/whoami
curl http://127.0.0.1:8080/config
```

Healthy signs:

- `/health` returns success
- `/whoami` returns hostname, pod IP, and app version
- `/config` returns safe config values and secret presence flags

## 3. Deployment and rollout checks

Use these during upgrades and rollback validation.

```bash
kubectl rollout status deployment/sample-app -n sample-app
kubectl get pods -n sample-app -w
kubectl get deployment sample-app -n sample-app
helm history sample-app -n sample-app
helm status sample-app -n sample-app
```

Healthy signs:

- rollout completes successfully
- old pods are replaced by new ones cleanly
- Helm release status is `deployed`

If rollout is stuck:

```bash
kubectl describe deployment sample-app -n sample-app
kubectl describe pod -n sample-app
kubectl logs -n sample-app deploy/sample-app
```

## 4. Scaling checks

### Manual scaling

```bash
kubectl scale deployment sample-app --replicas=2 -n sample-app
kubectl get deployment sample-app -n sample-app
kubectl get pods -n sample-app -o wide
kubectl get endpoints sample-app -n sample-app
```

Healthy signs:

- Deployment desired replicas matches the target
- additional Pods become `Running`
- Service endpoints include multiple Pod IPs

### HPA checks

```bash
kubectl get hpa -n sample-app
kubectl describe hpa sample-app -n sample-app
kubectl top pods -n sample-app
```

Healthy signs:

- HPA target metrics are visible
- current CPU value is shown
- desired replicas change when sustained load increases

If HPA is not working:

```bash
kubectl top nodes
kubectl top pods -n sample-app
kubectl logs -n kube-system deploy/metrics-server
```

Common issue:

- Metrics API unavailable means Metrics Server is missing or unhealthy

## 5. Availability protection checks

Use these to inspect the PodDisruptionBudget.

```bash
kubectl get pdb -n sample-app
kubectl describe pdb sample-app -n sample-app
```

Healthy signs:

- PDB exists
- selector matches the app Pods
- `Allowed disruptions` makes sense relative to current replica count

Important:

- PDB protects against voluntary disruptions such as drain or eviction
- PDB does not protect against app crashes or forced Pod deletion

## 6. External access checks

If the app is exposed through a `LoadBalancer` service:

```bash
kubectl get svc sample-app -n sample-app
kubectl describe svc sample-app -n sample-app
kubectl get endpoints sample-app -n sample-app
```

Healthy signs:

- Service type is correct
- external hostname exists
- endpoints are not empty

If DNS resolution fails:

```bash
kubectl get svc sample-app -n sample-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo
nslookup "$(kubectl get svc sample-app -n sample-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

If the hostname resolves but traffic fails:

```bash
kubectl describe svc sample-app -n sample-app
kubectl get endpoints sample-app -n sample-app
```

AWS-side checks:

```bash
aws elb describe-load-balancers --region eu-central-1
aws elb describe-instance-health --region eu-central-1 --load-balancer-name <elb-name>
aws ec2 describe-security-groups --region eu-central-1 --group-ids <elb-sg-id>
```

Common issue:

- ELB security group has no inbound rule for client traffic

## 7. Configuration and secret checks

Inspect the Kubernetes config resources:

```bash
kubectl get configmap -n sample-app
kubectl describe configmap sample-app-config -n sample-app
kubectl get secret -n sample-app
kubectl describe secret sample-app-secrets -n sample-app
```

Healthy signs:

- ConfigMap exists with expected keys
- Secret exists with expected keys
- app `/config` endpoint shows config present and secrets configured

Important:

- `describe secret` does not safely expose full secret values
- avoid printing secrets casually in shared environments

## 8. First-response debugging checklist

When something is broken, use this order:

1. Check deployment and pods

```bash
kubectl get deployment -n sample-app
kubectl get pods -n sample-app -o wide
```

2. Check pod details and events

```bash
kubectl describe pod -n sample-app
```

3. Check logs

```bash
kubectl logs -n sample-app deploy/sample-app
```

4. Check service and endpoints

```bash
kubectl get svc -n sample-app
kubectl get endpoints -n sample-app
```

5. Check runtime metrics

```bash
kubectl top pods -n sample-app
kubectl top nodes
```

6. Check HPA and PDB if scaling or availability are involved

```bash
kubectl describe hpa sample-app -n sample-app
kubectl describe pdb sample-app -n sample-app
```

## 9. Common failure patterns

### Pod is pending

Check:

```bash
kubectl describe pod -n sample-app
```

Likely causes:

- insufficient CPU or memory
- bad resource requests
- no node capacity

### Pod is crash looping

Check:

```bash
kubectl logs -n sample-app deploy/sample-app
kubectl describe pod -n sample-app
```

Likely causes:

- bad config
- missing secret
- bad application startup behavior

### Service exists but app is unreachable

Check:

```bash
kubectl get svc -n sample-app
kubectl get endpoints -n sample-app
kubectl describe svc sample-app -n sample-app
```

Likely causes:

- Service selector mismatch
- empty endpoints
- AWS load balancer security group issue

### HPA exists but does not scale

Check:

```bash
kubectl describe hpa sample-app -n sample-app
kubectl top pods -n sample-app
kubectl top nodes
```

Likely causes:

- Metrics Server not working
- load too low
- CPU requests too high or too low for the scaling target

## 10. Helm operational commands

Check release state:

```bash
helm list -n sample-app
helm status sample-app -n sample-app
helm history sample-app -n sample-app
```

Upgrade the app:

```bash
helm upgrade --install sample-app ./charts/sample-app -n sample-app -f charts/sample-app/values-dev.yaml
```

Rollback the app:

```bash
helm rollback sample-app <revision> -n sample-app
```

Render before applying:

```bash
helm template sample-app ./charts/sample-app -n sample-app -f charts/sample-app/values-dev.yaml
```

## 11. Routine operator checklist

For a quick daily or pre-deploy check:

```bash
kubectl get deployment -n sample-app
kubectl get pods -n sample-app
kubectl get svc -n sample-app
kubectl get hpa -n sample-app
kubectl get pdb -n sample-app
kubectl top pods -n sample-app
helm status sample-app -n sample-app
curl http://<load-balancer-hostname>/health
```

If all of those look healthy, the app is usually in a good operational state.
