#!/bin/bash
set -euo pipefail

SOCKET_PATH="${_BUILD_ARG_SOCKETPATH:-/root/.ssh/ssh-agent.sock}"
KEY_LIST="${_BUILD_ARG_KEYS:-}"
AGENT_ENV="/etc/profile.d/ssh-agent.sh"

echo "🔐 Setting up SSH agent..."

# Write agent startup logic with dynamic key loading
cat <<EOF > "$AGENT_ENV"
#!/bin/bash
export SSH_AUTH_SOCK="$SOCKET_PATH"
export SSH_AGENT_PID=""

if [ ! -S "\$SSH_AUTH_SOCK" ]; then
  echo "🔐 Starting new ssh-agent at \$SSH_AUTH_SOCK"
  eval "\$(ssh-agent -a \$SSH_AUTH_SOCK)" > /dev/null
  export SSH_AGENT_PID=\$SSH_AGENT_PID
fi

IFS="," read -ra KEYS <<< "$KEY_LIST"
for key in "\${KEYS[@]}"; do
  if [[ -f "\$key" ]]; then
    if ! ssh-add -l 2>/dev/null | grep -q "\$key"; then
      echo "➕ Adding key: \$key"
      ssh-add "\$key"
    fi
  fi
done
EOF

chmod +x "$AGENT_ENV"
echo "✅ SSH agent profile script created at $AGENT_ENV"
