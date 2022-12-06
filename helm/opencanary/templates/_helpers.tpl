{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Returns env_data_app_list correctly quoted
*/}}
{{- define "additional-env-data-app" }}
{{- $env_obj := .Values.env -}}
{{ if $env_obj.env_data_app_list -}}
{{- range $env_obj.env_data_app_list }}
{{-   $param_value := index $env_obj.inline . -}}
{{-   if $param_value }}
- name: {{ . }}
  value: {{ index $env_obj.inline . | quote }}
{{-   else -}}
{{-     fail (cat "value for" . "is not found, please define it in .Values.env.inline") -}}
{{-   end -}}

{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns env_data_namespace_list correctly quoted, ignore var if it exist on env_data_app_list
*/}}
{{- define "additional-env-data-namespace" -}}
{{- $values_obj := .Values -}}
{{- $env_obj := $values_obj.env -}}
{{- if $env_obj.env_data_namespace_list -}}
{{-   range $env_obj.env_data_namespace_list }}
{{-     $param_name := . -}}
{{-     if not (has $param_name $env_obj.env_data_app_list) }}
- name: {{ $param_name }}
  valueFrom:
    configMapKeyRef:
      name: {{ $.Release.Namespace }}-config
      key: {{ $param_name }}
{{-     end }}
{{-   end -}}
{{- end -}}
{{- end -}}