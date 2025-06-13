#!/bin/bash
set -euo pipefail

LOG_FILE="/usr/local/share/python-from-source.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
    echo "$@" | tee -a "$LOG_FILE"
}

log "📦 Python from source feature starting..."
log "📥 Raw input VARIANT: ${VARIANT:-unset}"
env | grep VARIANT | tee -a "$LOG_FILE"

# --- Config ---
if [[ -z "${VARIANT:-}" || "${VARIANT}" == "null" ]]; then
    PYTHON_VERSION="3.12"
    log "⚠️   VARIANT was not set or was null. Defaulting to: $PYTHON_VERSION"
else
    PYTHON_VERSION="$VARIANT"
    log "📥 Parsed input version: $PYTHON_VERSION"
fi

INSTALL_BASE="/usr/local"
INSTALL_PATH="${INSTALL_BASE}/python-${PYTHON_VERSION}"

BUILD_DEPS=(
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev
    liblzma-dev uuid-dev tk-dev make tar curl ca-certificates
)

main() {
    log "🔧 Running install steps..."

    if [[ "$PYTHON_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
        log "🔍 Looking up latest patch version for: $PYTHON_VERSION"
        ESCAPED_VERSION="$(echo "$PYTHON_VERSION" | sed 's/\./\\./g')"
        RESOLVED=$(curl -fsSL https://www.python.org/ftp/python/ \
            | grep -Eo "${ESCAPED_VERSION}\.[0-9]+/" \
            | sed 's|/||' \
            | sort -V | tail -n 1 || true)

        if [[ -z "$RESOLVED" ]]; then
            log "❌ Could not resolve full version from $PYTHON_VERSION"
            exit 1
        fi

        PYTHON_VERSION="$RESOLVED"
        INSTALL_PATH="${INSTALL_BASE}/python-${PYTHON_VERSION}"
        log "✅ Resolved full version: $PYTHON_VERSION"
    fi

    install_python
}

install_python() {
    log "📥 Installing Python $PYTHON_VERSION from source..."

    apt-get update
    apt-get install -y --no-install-recommends "${BUILD_DEPS[@]}"

    cd /tmp
    URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    log "📦 Downloading from: $URL"

    curl -fsSL -o Python.tgz "$URL"
    tar -xzf Python.tgz
    cd "Python-${PYTHON_VERSION}"

    ./configure --prefix="$INSTALL_PATH" --enable-optimizations
    make -j"$(nproc)"
    make install

    ln -sf "${INSTALL_PATH}/bin/python3" /usr/local/bin/python3
    ln -sf "${INSTALL_PATH}/bin/pip3" /usr/local/bin/pip3

    log "✅ Python $PYTHON_VERSION installed at $INSTALL_PATH"
    cleanup
}

cleanup() {
    log "🧹 Cleaning up..."
    apt-get purge -y "${BUILD_DEPS[@]}"
}

main
