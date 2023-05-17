{{/*
prints registry pull secret
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"username\":\"%s\", \"password\":\"%s\", \"auth\": \"%s\"}}}" .Values.global.imageCredentials.registry .Values.global.imageCredentials.username .Values.global.imageCredentials.password (printf "%s:%s" .Values.global.imageCredentials.username .Values.global.imageCredentials.password | b64enc) | b64enc }}
{{- end }}