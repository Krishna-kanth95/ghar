#!/bin/bash

# Replace these with your actual values
EFS_ID=file_system_id
MOUNT_DIRECTORY=/path/to/mount

# Install EFS mount helper
sudo yum install -y amazon-efs-utils

# Create the mount directory
sudo mkdir -p "$MOUNT_DIRECTORY"

# Mount the EFS
sudo mount -t efs -o tls "$EFS_ID:/" "$MOUNT_DIRECTORY"

# Check if EFS is already in fstab, add if not
if ! grep -qs "$EFS_ID:/" /etc/fstab; then
    echo "$EFS_ID:/ $MOUNT_DIRECTORY efs tls,_netdev 0 0" | sudo tee -a /etc/fstab
fi

# Remount all in fstab (with sudo)
sudo mount -a

# Optional: Uncomment to verify the EFS is mounted
# sudo mount -fav
