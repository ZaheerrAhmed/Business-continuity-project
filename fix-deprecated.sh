#!/bin/bash
echo "Fixing deprecated api_server_authorized_ip_ranges..."

# Backup
cp main.tf main.tf.backup.$(date +%s)

# Remove the deprecated attribute from ignore_changes
# Keep api_server_access_profile (the new way)
sed -i '/api_server_authorized_ip_ranges,/d' main.tf

echo "Fixed. Now the attribute is only referenced via api_server_access_profile."
