#!/bin/bash

LOGFILE="$HOME/update-log.txt"
DATE=$(date '+%a %d %b %Y %H:%M:%S %Z')
echo "Update-Protokoll vom $DATE" | tee "$LOGFILE"

update_container() {
    local container_id=$1
    echo "Aktualisiere Container $container_id" | tee -a "$LOGFILE"
    if pct status "$container_id" | grep -q running; then
        pct exec "$container_id" -- bash -c "export DEBIAN_FRONTEND=noninteractive; \
        locale-gen en_US.UTF-8 && \
        update-locale LANG=en_US.UTF-8 && \
        apt-get update && apt-get upgrade -y && apt-get autoremove -y" | tee -a "$LOGFILE" 2>&1
    else
        echo "Container $container_id läuft nicht." | tee -a "$LOGFILE"
    fi
}

# Liste der Container-IDs für Standard-Updates
standard_containers=(100 102 103 104 105 106 107 108 109 110 111 112 113 114 115)

# Liste der Container-IDs für spezielle Updates
pihole_containers=(101)

# Update Standard-Container
for container_id in "${standard_containers[@]}"; do
    update_container "$container_id"
done

# Update Pi-hole Container
for container_id in "${pihole_containers[@]}"; do
    echo "Aktualisiere Pi-hole in Container $container_id" | tee -a "$LOGFILE"
    if pct status "$container_id" | grep -q running; then
        pct exec "$container_id" -- bash -c "pihole -up" | tee -a "$LOGFILE" 2>&1
    else
        echo "Pi-hole Container $container_id läuft nicht." | tee -a "$LOGFILE"
    fi
done

echo "Update-Vorgang abgeschlossen." | tee -a "$LOGFILE"
