{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ks.hook.postInstall" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "{{ default -5 .hookWeight }}"
"helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
{{- end -}}

{{- define "ks.hook.postInstallOrUpgrade" -}}
"helm.sh/hook": post-install,post-upgrade
"helm.sh/hook-weight": "{{ default -5 .hookWeight }}"
"helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
{{- end -}}
