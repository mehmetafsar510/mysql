{{/*
prints ingress class metadata annotation depends on value existence
*/}}
{{- define "ks.ingress.class" -}}
  {{- if .Values.global.ingress.class -}}
kubernetes.io/ingress.class: {{ .Values.global.ingress.class }}
  {{- end -}}
{{- end -}}

{{/*
prints ingress basic auth metadata annotations
*/}}
{{- define "ks.ingress.basicAuth" -}}
# type of authentication
nginx.ingress.kubernetes.io/auth-type: basic
# name of the secret that contains the user/password definitions
nginx.ingress.kubernetes.io/auth-secret: {{ template "ks.fullname" . }}-basic-auth
# message to display with an appropriate context why the authentication is required
nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
{{- end -}}

{{- define "ks.ingress.manifest" -}}
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: {{ template "ks.fullname" . }}-{{ .ingress.hostPrefix }}
  labels: {{ include "ks.labels" . | nindent 4 }}
  annotations:
{{ include "ks.ingress.class" . | indent 4 }}
{{- with .ingress.annotations }}
{{ toYaml . | indent 4 }}
{{- end }}
spec:
{{- if .ingress.tlsSecretName }}
  tls:
    - hosts:
        - {{ .ingress.hostPrefix }}.{{ .Values.global.ingress.domain }}
      secretName: {{ .ingress.tlsSecretName }}
{{- end }}
  rules:
  - host: {{ .ingress.hostPrefix }}.{{ .Values.global.ingress.domain }}
    http:
      paths:
      - path: {{ .ingress.path }}
        backend:
          serviceName: {{ tpl .ingress.serviceName . }}
          servicePort: {{ tpl .ingress.servicePort . }}
{{- end }}