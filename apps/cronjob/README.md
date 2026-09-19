# ⏰ Scheduled CronJob Workload (`apps/cronjob/`)

> **Production Template for Batch Processing, Data Pipelines & Nightly Cleanup Tasks**

---

## 📋 Manifests in this Folder

* [`cronjob.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/cronjob.yaml) — Native scheduled Kubernetes CronJob (`batch/v1`) with UTC timezone, `concurrencyPolicy: Forbid`, and Spot instance tolerations.
* [`deployment.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/deployment.yaml) — Continuous scheduler daemon runner alternative (e.g. Celery Beat, Airflow scheduler).
* [`service.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/service.yaml) — Metrics service for Prometheus scraping.
* [`ingress.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/ingress.yaml) — Internal ingress for webhook-triggered ad-hoc batch jobs.
* [`configmap.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/configmap.yaml) — Batch task parameters and target bucket configurations.
* [`secret.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/secret.yaml) — Database credentials and API tokens.
* [`hpa.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/hpa.yaml) — Autoscaler for the continuous scheduler runner.
* [`serviceaccount.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/serviceaccount.yaml) — ServiceAccount with IRSA annotations for S3 exports and SES emails.
* [`pvc.yaml`](file:///media/nishath/New%20Volume/Cloud%20projects/devops-starter-kit/apps/cronjob/pvc.yaml) — Disk claim for batch export artifacts and database dumps.

---

## 🛠 Quick Customization

1. **Schedule**: Edit `schedule: "0 2 * * *"` in `cronjob.yaml` (format: `min hour day month weekday` in UTC).
2. **Concurrency**: Set `concurrencyPolicy: Forbid` (default) so a new run doesn't start if the previous is still executing.
3. **Trigger Manually**: You can manually trigger a CronJob run anytime:
   ```bash
   kubectl create job --from=cronjob/starter-cronjob manual-test-run -n apps
   ```

---

## 🧪 Testing

### Local KinD:
```bash
kubectl config use-context kind-bnp-cluster
kubectl apply -f apps/cronjob/configmap.yaml
kubectl apply -f apps/cronjob/secret.yaml
kubectl apply -f apps/cronjob/serviceaccount.yaml
kubectl apply -f apps/cronjob/cronjob.yaml

# Trigger an immediate manual test run:
kubectl create job --from=cronjob/starter-cronjob test-run-1 -n apps
kubectl get pods -n apps
kubectl logs job/test-run-1 -n apps
```

### Amazon EKS:
```bash
aws eks update-kubeconfig --region ap-south-1 --name <YOUR_EKS_CLUSTER>
kubectl apply -f apps/cronjob/ -n apps
```
