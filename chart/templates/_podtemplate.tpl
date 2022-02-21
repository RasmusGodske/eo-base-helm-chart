{{- define "eo-base-helm-chart.podTemplate" -}}
containers:
  - name: {{ .root.Chart.Name }}-{{ .name }}
    image: "{{ .deployment.image.repository }}:{{ .deployment.image.tag }}"
    imagePullPolicy: {{ .deployment.image.pullPolicy }}
    {{- if .deployment.command }}
    command: [{{ .deployment.command | quote }}]
    {{- if .deployment.args }}
    args: [{{ .deployment.args | quote }}]
    {{- end}}
    {{- end}}
    ports:
      - name: http
        containerPort: 80
        protocol: TCP
    {{- if .deployment.probes }}
    livenessProbe:
      httpGet:
        path: /health
        port: http
    readinessProbe:
      httpGet:
        path: /health
        port: http
    {{- end }}
    {{- if (or .deployment.env .root.Values.env .root.Values.envSecrets) }}
    env:
    {{- if .root.Values.env}}
    {{- range $name, $value := .root.Values.env }}
      - name: {{ $name }}
        value: {{ $value | quote }}
    {{- end}}
    {{- end}}
    {{- if .deployment.env}}
    {{- range $name, $value := .deployment.env }}
      - name: {{ $name }}
        value: {{ $value | quote }}
    {{- end}}
    {{- end}}
    {{- if .root.Values.envSecrets}}
    {{- range $name, $value := .root.Values.envSecrets }}
      - name: {{ $name }}
        valueFrom:
          secretKeyRef:
            name: {{ $value.secretName }}
            key: {{ $value.key }}
    {{- end}}
    {{- end}}
    {{- end}}
    {{- if .root.Values.configMaps}}
    volumeMounts:
    {{- range $name, $value := .root.Values.configMaps }}
      - name: {{ $name }}
        mountPath: {{ $value.mountPath }}
        readOnly: {{ $value.readOnly }}
    {{- end }}
    {{- end }}
    {{- if .deployment.containerSpec }}
    {{- with .deployment.containerSpec }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- end }}
{{- if .deployment.podSpec }}
{{- with .deployment.podSpec }}
{{- toYaml . | nindent 0}}
{{- end }}
{{- end }}
{{- if .root.Values.configMaps}}
{{- range $name, $value := .root.Values.configMaps }}
volumes:
  - name: {{ $name }}
    configMap:
      name: {{ $name }}
{{- end }}
{{- end }}
{{ end -}}
