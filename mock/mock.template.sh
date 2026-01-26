#!/bin/sh

set -eu

# Copy this file to mock/mock.local.sh and fill in values.

ACCESS_KEY_ID=""
ACCESS_KEY_SECRET=""
DOMAIN=""
RR="@"
TYPE="A"
TTL="600"
IP_SOURCE="wan"
IP_OVERRIDE="1.2.3.4"
INTERVAL="300"
LOG_PATH="/dev/stderr"
API_ENDPOINT="https://alidns.aliyuncs.com/"
API_VERSION="2015-01-09"
MODE="sync"
RECORD_ID=""
VALUE=""
PAGE_SIZE="100"
LIST_RR=""
LIST_TYPE=""
COMMAND="--once"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)

# Provide a minimal UCI/ubus environment via env vars for the script.
export MOCK_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export MOCK_ACCESS_KEY_SECRET="$ACCESS_KEY_SECRET"
export MOCK_DOMAIN="$DOMAIN"
export MOCK_RR="$RR"
export MOCK_TYPE="$TYPE"
export MOCK_TTL="$TTL"
export MOCK_IP_SOURCE="$IP_SOURCE"
export MOCK_IP_OVERRIDE="$IP_OVERRIDE"
export MOCK_INTERVAL="$INTERVAL"
export MOCK_LOG_PATH="$LOG_PATH"
export MOCK_API_ENDPOINT="$API_ENDPOINT"
export MOCK_API_VERSION="$API_VERSION"
export MOCK_MODE="$MODE"
export MOCK_RECORD_ID="$RECORD_ID"
export MOCK_VALUE="$VALUE"
export MOCK_PAGE_SIZE="$PAGE_SIZE"
export MOCK_LIST_RR="$LIST_RR"
export MOCK_LIST_TYPE="$LIST_TYPE"

# Use mock binaries first.
PATH="${SCRIPT_DIR}:$PATH" \
	/bin/sh "${REPO_ROOT}/src/usr/bin/aliddns.sh" ${COMMAND}
