
#!/usr/bin/env bash

set -e

# =========================
# USER CONFIG
# =========================

# Require environment variables for security
AUTH_KEY=${AUTH_KEY:?AUTH_KEY environment variable not set}
API_KEY=${API_KEY:?API_KEY environment variable not set}

TAILNET="shell-NET"

ENABLE_SSH=true

# =========================

echo "======================================"
echo "Tailscale Zero-Touch Exit Node Deploy"
echo "======================================"

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG="yum"
else
    echo "Unsupported Linux distribution"
    exit 1
fi

echo "Detected package manager: $PKG"

# Install dependencies
if [ "$PKG" = "apt" ]; then
    apt update -y
    apt install -y curl jq openssl unattended-upgrades
else
    $PKG install -y curl jq openssl
fi

# Install Tailscale
if command -v tailscale >/dev/null 2>&1; then
    echo "Tailscale already installed"
else
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# Enable auto updates
if [ "$PKG" = "apt" ]; then
    apt install -y unattended-upgrades
    dpkg-reconfigure -f noninteractive unattended-upgrades
fi

# Detect location
echo "Detecting server location..."

CITY=$(curl -s https://ipapi.co/json | jq -r '.city' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

SUFFIX=$(openssl rand -hex 2)

HOSTNAME="exitnode-$CITY-$SUFFIX"

echo "Hostname will be: $HOSTNAME"

# Enable IP forwarding
tee /etc/sysctl.d/99-tailscale-exit-node.conf > /dev/null <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

sysctl --system > /dev/null

# Start service
systemctl enable --now tailscaled

echo "Connecting to Tailscale..."

tailscale up \
--authkey=$AUTH_KEY \
--hostname=$HOSTNAME \
--advertise-exit-node \
--accept-routes \
--ssh

sleep 5

# Get device ID
echo "Retrieving device ID..."

NODE_ID=$(sudo tailscale status --json | jq -r '.Self.ID')

echo "Node ID: $NODE_ID"

# Approve exit node automatically
echo "Auto-approving exit node..."

curl -s -X POST \
-u "$API_KEY:" \
"https://api.tailscale.com/api/v2/device/$NODE_ID/routes" \
-H "Content-Type: application/json" \
-d '{
"routes": ["0.0.0.0/0", "::/0"]
}' > /dev/null

echo ""
echo "======================================"
echo "INSTALLATION COMPLETE"
echo ""
echo "Device hostname: $HOSTNAME"
echo "Tags: $TAGS"
echo "Exit node enabled and approved"
echo ""
echo "Node is ready for use."
echo "======================================"

