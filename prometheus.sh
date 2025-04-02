#!/bin/sh
/nix/store/dgzwnhq3ahbk1ahb85xjz3351id7mzxm-prometheus-3.1.0/bin/prometheus \
  --config.file=$(pwd)/prometheus.yml \
  --storage.tsdb.path=$(pwd)/data/prometheus
