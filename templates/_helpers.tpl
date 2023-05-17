{{- define "ks._commonNameLength" -}}
{{- if .Values.global.limits -}}{{- .Values.global.limits.lengths.commonName -}}{{- else -}}63{{- end -}}
{{- end -}}

{{- define "ks._releaseNameLength" -}}
{{- if .Values.global.limits -}}{{- .Values.global.limits.lengths.releaseName -}}{{- else -}}8{{- end -}}
{{- end -}}

{{- define "ks._fullnameLength" -}}
{{- if .Values.global.limits -}}{{- .Values.global.limits.lengths.fullname -}}{{- else -}}13{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ks.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc (include "ks._commonNameLength" . | int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Fullname generator
*/}}
{{- define "ks._fullnameGenerator" -}}
{{- printf "%s-%s" (.Release.Name | trunc (include "ks._releaseNameLength" . | int)) .name | trunc (include "ks._fullnameLength" . | int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Tries to re-create the fully qualified app name of another subchart.
Only works if neither fullnameOverride nor nameOverride are set for the other subchart
*/}}
{{- define "ks.siblingFullname" -}}
{{- include "ks._fullnameGenerator" (merge (dict "name" .sibling) .) }}
{{- end -}}

{{/*
Create a default fully qualified app name.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ks.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc (include "ks._fullnameLength" . | int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- include "ks._fullnameGenerator" (merge (dict "name" $name) .) }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ks.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc (include "ks._commonNameLength" . | int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ks.labels" -}}
helm.sh/chart: {{ include "ks.chart" . }}
{{ include "ks.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.partof }}
app.kubernetes.io/part-of: {{ .Values.partof }}
{{- end }}
{{- if .Values.component }}
app.kubernetes.io/component: {{ .Values.component }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "ks.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ks.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .service }}
app.kubernetes.io/service: {{ .service }}
{{- else if .Values.nameOverride }}
app.kubernetes.io/service: {{ .Values.nameOverride }}
{{- end }}
{{- end -}}

{{/*
Workload spec labels for created pods
*/}}
{{- define "ks.workloadPodLabels" -}}
{{ include "ks.labels" . }}
{{- if .Values.global.labels }}
{{ .Values.global.labels.workloadPod | toYaml }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ks.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ks.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common dynamic annotations
*/}}
{{- define "ks.commonAnnotations" -}}
{{- if .Values.global.annotations }}
{{ .Values.global.annotations.common | toYaml }}
{{- end }}
{{- end -}}

{{/*
Workload dynamic annotations
*/}}
{{- define "ks.workloadAnnotations" -}}
{{ include "ks.commonAnnotations" . }}
{{- if .Values.global.annotations }}
{{ .Values.global.annotations.workload | toYaml }}
{{- end }}
{{- end -}}

{{/*
Fulname of kong
*/}}
{{- define "ks.kongFullname" -}}
{{- printf "%s-%s" .Release.Name "kong" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clear-pipeline.fullname" -}}
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
Create the name of the service account to use
*/}}
{{- define "clear-pipeline.serviceAccountName" -}}
{{- if .Values.global.pipelines.serviceAccount.create }}
{{- default (include "clear-pipeline.fullname" .) .Values.global.pipelines.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.global.pipelines.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "emoney.podAnnotations" -}}
traffic.sidecar.istio.io/excludeInboundPorts: '9090'
{{- if .Values.podAnnotations }}
{{ .Values.podAnnotations | toYaml }}
{{- end -}}
{{- if $.Values.urls }}
checksum/{{ $.Chart.Name }}-url-config: {{ include (print $.Template.BasePath "/url-config.yaml") . | sha256sum }}
{{- end }}
{{- if $.Values.configMaps | empty | not -}}
{{- range keys $.Values.configMaps | sortAlpha -}}
{{- $type := (get $.Values.configMaps . ).type -}}
{{- if eq $type "env" -}}
{{- $configMapPath := printf "emoney/templates/configmap/%s.yaml" . }}
checksum/{{ . }}: {{ include $configMapPath $ | sha256sum | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $.Values.secrets | empty | not -}}
{{- range keys $.Values.secrets | sortAlpha -}}
{{- $type := (get $.Values.secrets . ).type -}}
{{- if eq $type "env" -}}
{{- $secretPath := printf "emoney/templates/secret/%s.yaml" . }}
checksum/{{ . }}: {{ include $secretPath $ | sha256sum | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}