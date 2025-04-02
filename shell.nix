{
  pkgs ? import <nixpkgs> {}
}:

pkgs.mkShell {
  name = "go-lgtm-stack";
  buildInputs = with pkgs; [
    go_1_24
    grafana
    grafana-loki
    tempo
    mimir
    tmux #Because ghostty window split sucks
  ];

  shellHook = ''
      # Check if mod exists
      if [ ! -f go.mod ]; then
        go mod init github.com/kayYZ1/go-lgtm-stack
      fi

      # Install/Update modules
      go mod tidy

      mkdir -p ./data

      # Grafana config file
      echo "[server]" > grafana.ini
      echo "http_addr = 127.0.0.1" >> grafana.ini
      echo "http_port = 3333" >> grafana.ini
      echo "[paths]" >> grafana.ini
      echo "data = $(pwd)/data/grafana" >> grafana.ini

      # Grafana shell script
      cat > grafana.sh <<'EOF'
      #!/bin/sh
      ${pkgs.grafana}/bin/grafana server \
        --homepath=${pkgs.grafana}/share/grafana \
        --config=$(pwd)/grafana.ini
      EOF
      chmod +x grafana.sh

      # Prometheus config file
      cat > prometheus.yml <<'EOF'
      global:
        scrape_interval: 15s
      scrape_configs:
        - job_name: 'go_app'
          static_configs:
            - targets: ['localhost:8081']
      remote_write:
        - url: "http://localhost:9009/api/v1/push"
      EOF

      # Prometheus shell script
      cat > prometheus.sh <<'EOF'
      #!/bin/sh
      ${pkgs.prometheus}/bin/prometheus \
        --config.file=$(pwd)/prometheus.yml \
        --storage.tsdb.path=$(pwd)/data/prometheus
      EOF
      chmod +x prometheus.sh

      # Mimir shell script (monolithic mode for simplicity)
      cat > mimir.sh <<'EOF'
      #!/bin/sh
      ${pkgs.mimir}/bin/mimir \
        2-target=all \
        -server.http-listen-port=9009 \
        -auth.multitenancy-enabled=false \
        -activity-tracker.filepath=$(pwd)/data/mimir-activity.log \
        -blocks-storage.tsdb.dir=$(pwd)/data/mimir-tsdb \
        -blocks-storage.backend=filesystem \
        -ingester.ring.replication-factor=1
      EOF
      chmod +x mimir.sh

      echo "http://localhost:3333 (default login: admin/admin) -> ./grafana.sh"
      echo "http://localhost:8081 -> go run main.go"
      echo "http://localhost:9090 -> ./prometheus.sh"
      echo "http://localhost:9009/prometheus -> ./mimir.sh"
    '';
}
