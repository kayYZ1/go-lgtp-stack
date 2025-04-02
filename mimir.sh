#!/bin/sh
/nix/store/iknnp95z80j4ag4d9fy4lf9d13hn1vi4-mimir-2.15.0/bin/mimir \
  2-target=all \
  -server.http-listen-port=9009 \
  -auth.multitenancy-enabled=false \
  -activity-tracker.filepath=$(pwd)/data/mimir-activity.log \
  -blocks-storage.tsdb.dir=$(pwd)/data/mimir-tsdb \
  -blocks-storage.backend=filesystem \
  -ingester.ring.replication-factor=1
