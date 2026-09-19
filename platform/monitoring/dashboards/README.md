# platform/monitoring/dashboards/README.md
# ------------------------------------------------------------------------------
# Grafana Dashboards Directory
# ------------------------------------------------------------------------------
#
# Place Grafana dashboard JSON files here. They will be automatically
# loaded by the Grafana sidecar when wrapped in a ConfigMap with the label:
#   grafana_dashboard: "1"
#
# How to add a dashboard:
#   1. Export your dashboard JSON from Grafana UI (Share → Export → Save to file).
#   2. Copy the JSON file here.
#   3. Create a ConfigMap wrapping the JSON:
#
#   kubectl create configmap my-dashboard \
#     --from-file=dashboard.json=./my-dashboard.json \
#     --namespace=monitoring
#   kubectl label configmap my-dashboard grafana_dashboard="1" -n monitoring
#
#   Or commit the ConfigMap as YAML so ArgoCD manages it.
#
# Dashboard sources:
#   - Grafana.com: https://grafana.com/grafana/dashboards/
#     Recommended IDs:
#       315  — Kubernetes cluster monitoring
#       13770 — 1 Node Exporter for Prometheus Dashboard
#       6417  — Kubernetes Cluster (Prometheus)
#       11074 — Node Exporter Full
#       12740 — Kubernetes Persistent Volumes
#
# GitOps-managed dashboard example: see apps/backend/configmap.yaml for annotation.
