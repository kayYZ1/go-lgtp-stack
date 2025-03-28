#!/bin/sh
/nix/store/ajn0l3ywzm7k6jh53a4xmh83crz1d26w-grafana-11.5.1/bin/grafana server \
--homepath=/nix/store/ajn0l3ywzm7k6jh53a4xmh83crz1d26w-grafana-11.5.1/share/grafana \
--config=$(pwd)/grafana.ini
