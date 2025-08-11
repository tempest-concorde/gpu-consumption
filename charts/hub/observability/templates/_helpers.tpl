{{/*
Expand the name of the chart.
*/}}
{{- define "observability.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "observability.fullname" -}}
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
{{- define "observability.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "observability.labels" -}}
helm.sh/chart: {{ include "observability.chart" . }}
{{ include "observability.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "observability.selectorLabels" -}}
app.kubernetes.io/name: {{ include "observability.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
AWS Region detection - try to get from cluster metadata or use configured value
*/}}
{{- define "observability.aws.region" -}}
{{- if .Values.global.aws.region }}
{{- .Values.global.aws.region }}
{{- else }}
{{- "us-east-1" }}
{{- end }}
{{- end }}

{{/*
S3 Bucket name generation
*/}}
{{- define "observability.s3.bucketName" -}}
{{- if .Values.thanos.objectStorage.s3.bucketName }}
{{- .Values.thanos.objectStorage.s3.bucketName }}
{{- else }}
{{- printf "%s-thanos-object-storage" (.Values.global.pattern | default "gpu-consumption") }}
{{- end }}
{{- end }}

{{/*
Generate S3 endpoint URL
*/}}
{{- define "observability.s3.endpoint" -}}
{{- printf "s3.%s.amazonaws.com" (include "observability.aws.region" .) }}
{{- end }}
