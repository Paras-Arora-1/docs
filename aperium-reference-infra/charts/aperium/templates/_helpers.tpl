{{/*
Expand the name of the chart.
*/}}
{{- define "aperium.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "aperium.fullname" -}}
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
Backend and frontend resource names.
*/}}
{{- define "aperium.backendFullname" -}}
{{- printf "%s-backend" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "aperium.frontendFullname" -}}
{{- printf "%s-frontend" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "aperium.workerFullname" -}}
{{- printf "%s-document-worker" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "aperium.schedulerFullname" -}}
{{- printf "%s-background-scheduler" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "aperium.workerKedaConnectionSecretName" -}}
{{- printf "%s-document-worker-keda-connection" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "aperium.sharedStorageClaimName" -}}
{{- if .Values.sharedStorage.claimName -}}
{{- .Values.sharedStorage.claimName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-shared" (include "aperium.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aperium.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aperium.labels" -}}
helm.sh/chart: {{ include "aperium.chart" . }}
{{ include "aperium.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common backend labels
*/}}
{{- define "aperium.backendLabels" -}}
helm.sh/chart: {{ include "aperium.chart" . }}
{{ include "aperium.backendSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common frontend labels
*/}}
{{- define "aperium.frontendLabels" -}}
helm.sh/chart: {{ include "aperium.chart" . }}
{{ include "aperium.frontendSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common worker labels
*/}}
{{- define "aperium.workerLabels" -}}
helm.sh/chart: {{ include "aperium.chart" . }}
{{ include "aperium.workerSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common scheduler labels
*/}}
{{- define "aperium.schedulerLabels" -}}
helm.sh/chart: {{ include "aperium.chart" . }}
{{ include "aperium.schedulerSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aperium.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "aperium.backendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium.name" . }}-backend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "aperium.frontendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "aperium.workerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium.name" . }}-document-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Scheduler selector labels
*/}}
{{- define "aperium.schedulerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "aperium.name" . }}-background-scheduler
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "aperium.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aperium.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
