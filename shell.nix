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
      #Check if mod exists
      if [ ! -f go.mod ]; then
        go mod init github.com/kayYZ1/go-lgtm-stack
      fi

      #Install/Update modules
      go mod tidy

      mkdir -p ./data

      #Grafana config file
      echo "[server]" > grafana.ini
      echo "http_addr = 127.0.0.1" >> grafana.ini
      echo "http_port = 3333" >> grafana.ini
      echo "[paths]" >> grafana.ini
      echo "data = $(pwd)/data" >> grafana.ini

      #Grafana shell script
      cat > grafana.sh <<'EOF'
      #!/bin/sh
      ${pkgs.grafana}/bin/grafana server \
      --homepath=${pkgs.grafana}/share/grafana \
      --config=$(pwd)/grafana.ini
      EOF
      chmod +x grafana.sh

      echo "http://localhost:3333 (default login: admin/admin) -> ./grafana.sh"
      echo "http://localhost:8081 -> go run ."
    '';
}
