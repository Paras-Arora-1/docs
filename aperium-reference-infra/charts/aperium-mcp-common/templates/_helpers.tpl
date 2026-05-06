{{/*
Expand the name of the chart.
*/}}
{{- define "aperium-mcp-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "aperium-mcp-common.fullname" -}}
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
{{- define "aperium-mcp-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aperium-mcp-common.labels" -}}
helm.sh/chart: {{ include "aperium-mcp-common.chart" . }}
{{ include "aperium-mcp-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aperium-mcp-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium-mcp-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "aperium-mcp-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aperium-mcp-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
CloudSQL sidecar container
*/}}
{{- define "aperium-mcp-common.cloudsqlSidecar" -}}
# Setup a cloudsql iam auth proxy sidecar; see: https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#run_the_in_a_sidecar_pattern
name: cloud-sql-proxy
# It is recommended to use the latest version of the Cloud SQL Auth Proxy
# Make sure to update on a regular schedule!
image: {{ .Values.cloudsql.image.url }}:{{ .Values.cloudsql.image.tag }}
args:
  - "--private-ip"
  - "--run-connection-test"
  - "--auto-iam-authn"
  - "--structured-logs"
  - "--port=5432"
  - {{ .Values.cloudsql.connectString }}
securityContext:
  # The default Cloud SQL Auth Proxy image runs as the
  # "nonroot" user and group (uid: 65532) by default.
  runAsNonRoot: true
resources:
  {{- toYaml .Values.cloudsql.resources | nindent 2 }}
{{- end }}
