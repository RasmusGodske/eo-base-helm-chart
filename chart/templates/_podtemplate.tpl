{{- define "ett-base-helm-chart.podTemplate" }}
      containers:
        - name: {{ $.Chart.Name }}-{{ .name }}
          image: "{{ .image.repository }}:{{ .image.tag }}"
          imagePullPolicy: {{ .image.pullPolicy }}
          {{- if .command }}
          command: [{{ .command | quote }}]
          {{- if .args }}
          args: [{{ .args | quote }}]
          {{- end}}
          {{- end}}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          {{- if .probes }}
          livenessProbe:
            httpGet:
              path: /health
              port: http
          readinessProbe:
            httpGet:
              path: /health
              port: http
          {{- end }}
          {{- if (or .env $.env $.envSecrets) }}
          env:
          {{- if $.env}}
          {{- range $name, $value := $.env }}
            - name: {{ $name }}
              value: {{ $value | quote }}
          {{- end}}
          {{- end}}
          {{- if .env}}
          {{- range $name, $value := .env }}
            - name: {{ $name }}
              value: {{ $value | quote }}
          {{- end}}
          {{- end}}
          {{- if $.envSecrets}}
          {{- range $name, $value := $.envSecrets }}
          - name: {{ $name }}
            valueFrom:
              secretKeyRef:
                name: {{ $value.secretName }}
                key: {{ $value.key }}
          {{- end}}
          {{- end}}
          {{- end}}
{{ end -}}
