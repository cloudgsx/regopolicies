#!/bin/bash

# Setup systemd service to run on boot
# Usage: ./setup_boot_service.sh YOUR-BUCKET-NAME

if [ -z "$1" ]; then
    echo "Usage: $0 <s3-bucket-name>"
    exit 1
fi

BUCKET_NAME=$1

echo "Setting up systemd service to run on boot..."
echo "Bucket: $BUCKET_NAME"

# Create systemd service file
cat > /etc/systemd/system/metadata-to-s3-boot.service <<SERVICE_EOF
[Unit]
Description=EC2 Metadata to S3 Upload on Boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /opt/metadata-to-s3/metadata_to_s3.py $BUCKET_NAME
StandardOutput=journal
StandardError=journal
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable metadata-to-s3-boot.service

echo ""
echo "✓ Boot service configured successfully!"
echo ""
echo "The metadata will be collected and uploaded to S3 on every boot."
echo ""
echo "Useful commands:"
echo "  systemctl status metadata-to-s3-boot.service   # Check service status"
echo "  journalctl -u metadata-to-s3-boot.service      # View logs"
echo "  systemctl start metadata-to-s3-boot.service    # Test run now"
echo "  systemctl disable metadata-to-s3-boot.service  # Disable auto-start"
echo ""
echo "To test without rebooting:"
echo "  sudo systemctl start metadata-to-s3-boot.service"
