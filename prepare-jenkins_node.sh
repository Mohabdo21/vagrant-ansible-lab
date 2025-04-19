#!/bin/bash

# Jenkins Node Setup Script
# This script prepares a Ubuntu/Debian system to be a Jenkins agent node

# Variables - customize these before running
JENKINS_CONTROLLER_URL="http://192.168.56.12:8080"
JENKINS_AGENT_SECRET="723d31db748891d2dfc96702cc1be63c2a5a0879adedf0387118cd2b7e1606ee"
JENKINS_AGENT_NAME="ats-saas"
JENKINS_HOME="/var/jenkins_home"
SERVICE_DIR="/usr/local/jenkins-service"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update package index
echo "Updating package index..."
apt-get update -qq

# Install Java Runtime Environment
echo "Installing Java Runtime Environment..."
apt-get install -qq -y default-jre

# Create Jenkins user
if ! id -u jenkins >/dev/null 2>&1; then
    echo "Creating jenkins user..."
    useradd -r -md "$JENKINS_HOME" -s /bin/bash jenkins
else
    echo "Jenkins user already exists"
fi

# Create service directory
echo "Setting up service directory at $SERVICE_DIR..."
mkdir -p "$SERVICE_DIR"
chown jenkins:jenkins -R "$SERVICE_DIR"

# Create agent startup script
echo "Creating agent startup script..."
cat > "$SERVICE_DIR/start-agent.sh" <<EOF
#!/bin/bash

cd "$SERVICE_DIR"
echo "Downloading agent.jar from Jenkins controller..."
curl -sO "$JENKINS_CONTROLLER_URL/jnlpJars/agent.jar"

echo "Starting Jenkins agent..."
exec java -jar agent.jar \
    -url "$JENKINS_CONTROLLER_URL" \
    -secret "$JENKINS_AGENT_SECRET" \
    -name "$JENKINS_AGENT_NAME" \
    -webSocket \
    -workDir "$SERVICE_DIR"
EOF

# Set permissions on startup script
chmod +x "$SERVICE_DIR/start-agent.sh"
chown jenkins:jenkins "$SERVICE_DIR/start-agent.sh"

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/jenkins-agent.service <<EOF
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
User=jenkins
WorkingDirectory=$JENKINS_HOME
ExecStart=/bin/bash $SERVICE_DIR/start-agent.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
echo "Enabling and starting Jenkins agent service..."
systemctl daemon-reload
systemctl enable jenkins-agent
systemctl start jenkins-agent

# Check service status
echo "Checking service status..."
sleep 3 # Give it a moment to start
systemctl status jenkins-agent --no-pager

echo "Jenkins agent setup complete!"
echo "Node should now appear in your Jenkins controller at $JENKINS_CONTROLLER_URL"
