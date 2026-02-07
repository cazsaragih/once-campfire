#!/bin/bash
set -e

# Fix permissions on mounted volumes (runs as root)
mkdir -p /rails/storage/db
chown -R rails:rails /rails/storage

# Drop to rails user and exec CMD
exec su rails -s /bin/bash -c "$*"
