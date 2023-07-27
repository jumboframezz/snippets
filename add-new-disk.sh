#!/bin/bash
for scsi_host in $(ls /sys/class/scsi_host/); do
    echo "Scanning: $scsi_host"
    echo "- - -" > /sys/class/scsi_host/$scsi_host/scan
done