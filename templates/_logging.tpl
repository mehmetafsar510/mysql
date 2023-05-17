{{/*
prints log sidecar configuration

Context:
  .name - container name
  .logfile - log file name
*/}}
{{- define "ks.logging.tailLogSidecar.container" -}}
{{- if .Values.global.logging.tailLogSidecar.enabled -}}
- name: {{ .name }}
  volumeMounts:
    - name: log-dir
      mountPath: "/logs"
  image: {{ .Values.global.logging.tailLogSidecar.image }}
  args: [/bin/sh, -c, 'tail -F -n+1 /logs/{{ .logfile }}']
{{- end -}}
{{- end -}}
