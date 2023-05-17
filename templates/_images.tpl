{{/*
Returns consolidated and deduplicated image pull secrets from .Values.global.imagePullSecrets and .Values.imagePullSecrets.
{{- include "ks.imagePullSecrets" . | nindent 6 }}
*/}}
{{- define "ks.imagePullSecrets" -}}
  {{- $imagePullSecrets := list }}

  {{- if .Values.global.imagePullSecrets }}
    {{- range .Values.global.imagePullSecrets -}}
      {{- $imagePullSecrets = append $imagePullSecrets . | uniq -}}
    {{- end -}}
  {{- end -}}

  {{- if .Values.imagePullSecrets }}
    {{- range .Values.imagePullSecrets -}}
      {{- range . -}}
        {{- $imagePullSecrets = append $imagePullSecrets . | uniq -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $imagePullSecrets)) -}}
imagePullSecrets:
    {{- range $imagePullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}

{{- end -}}
