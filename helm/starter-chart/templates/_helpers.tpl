{{/*
helm/starter-chart/templates/_helpers.tpl
-------------------------------------------------------------------------------
Template helpers for starter-chart.
These named templates generate consistent labels, names, and selectors.
-------------------------------------------------------------------------------
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "starter-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated to 63 chars because Kubernetes name fields are limited.
If Release.Name already contains the chart name, avoids duplication.
*/}}
{{- define "starter-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "starter-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels — applied to all resources.
*/}}
{{- define "starter-chart.labels" -}}
helm.sh/chart: {{ include "starter-chart.chart" . }}
{{ include "starter-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment | default "dev" }}
project: {{ .Values.global.project | default "starter" }}
{{- end }}

{{/*
Selector labels — used in Deployment selector and Service selector.
Must be stable — changing these requires recreating the Deployment.
*/}}
{{- define "starter-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "starter-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name — use override if provided, otherwise auto-generate.
*/}}
{{- define "starter-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "starter-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image string — combines repository and tag.
*/}}
{{- define "starter-chart.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
