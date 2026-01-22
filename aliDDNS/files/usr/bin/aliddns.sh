#!/bin/sh

set -eu

CONFIG=aliddns
CONFIG_SECTION=main
API_ENDPOINT="https://alidns.aliyuncs.com/"
VERSION="2015-01-09"

log() {
	local message="$1"
	if [ -n "${LOG_PATH:-}" ]; then
		printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$message" >> "$LOG_PATH"
	else
		logger -t aliddns "$message"
	fi
}

load_config() {
	ENABLED=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.enabled || echo 0)
	ACCESS_KEY_ID=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.access_key_id || echo "")
	ACCESS_KEY_SECRET=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.access_key_secret || echo "")
	DOMAIN=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.domain || echo "")
	RR=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.rr || echo "@")
	TYPE=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.type || echo "A")
	TTL=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.ttl || echo "600")
	IP_SOURCE=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.ip_source || echo "wan")
	IP_OVERRIDE=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.ip_override || echo "")
	INTERVAL=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.interval || echo "300")
	LOG_PATH=$(uci -q get ${CONFIG}.${CONFIG_SECTION}.log_path || echo "")
}

url_encode() {
	local input="$1"
	local output=""
	local i char
	for i in $(seq 1 ${#input}); do
		char="$(printf '%s' "$input" | cut -c $i)"
		case "$char" in
			[a-zA-Z0-9.~_-])
				output="$output$char"
				;;
			*)
				output="$output$(printf '%%%02X' "'"$char")"
				;;
		esac
	done
	printf '%s' "$output"
}

sign_request() {
	local canonicalized="$1"
	printf '%s' "$canonicalized" \
		| openssl dgst -sha1 -hmac "${ACCESS_KEY_SECRET}&" -binary \
		| openssl base64
}

aliyun_request() {
	local action="$1"
	shift
	local timestamp nonce signature signature_encoded query

	timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
	nonce=$(cat /proc/sys/kernel/random/uuid)

	local params="AccessKeyId=${ACCESS_KEY_ID}&Action=${action}&Format=JSON&SignatureMethod=HMAC-SHA1&SignatureNonce=${nonce}&SignatureVersion=1.0&Timestamp=${timestamp}&Version=${VERSION}"
	for param in "$@"; do
		params="${params}&${param}"
	done

	local sorted
	sorted=$(printf '%s' "$params" | tr '&' '\n' | sort | tr '\n' '&' | sed 's/&$//')

	local encoded
	encoded=$(printf '%s' "$sorted" | tr '&' '\n' | while IFS='=' read -r key value; do
		printf '%s=%s&' "$(url_encode "$key")" "$(url_encode "$value")"
	done | sed 's/&$//')

	local canonicalized="GET&%2F&$(url_encode "$encoded")"
	signature=$(sign_request "$canonicalized")
	signature_encoded=$(url_encode "$signature")

	query="${encoded}&Signature=${signature_encoded}"
	curl -fsS "${API_ENDPOINT}?${query}"
}

get_interface_ip() {
	local iface="$1"
	ubus call network.interface."$iface" status 2>/dev/null \
		| jsonfilter -e '@["ipv4-address"][0].address'
}

get_current_ip() {
	if [ -n "$IP_OVERRIDE" ]; then
		printf '%s' "$IP_OVERRIDE"
		return
	fi

	local ip
	ip=$(get_interface_ip "$IP_SOURCE" || true)
	if [ -z "$ip" ]; then
		log "Failed to get IP from interface ${IP_SOURCE}"
		return 1
	fi
	printf '%s' "$ip"
}

get_record_info() {
	local response record_id record_value
	response=$(aliyun_request "DescribeDomainRecords" "DomainName=${DOMAIN}" "RRKeyWord=${RR}" "TypeKeyWord=${TYPE}")
	record_id=$(printf '%s' "$response" | jsonfilter -e '@.DomainRecords.Record[0].RecordId')
	record_value=$(printf '%s' "$response" | jsonfilter -e '@.DomainRecords.Record[0].Value')
	printf '%s|%s' "$record_id" "$record_value"
}

update_record() {
	local record_id="$1"
	local ip="$2"
	aliyun_request "UpdateDomainRecord" "RecordId=${record_id}" "RR=${RR}" "Type=${TYPE}" "Value=${ip}" "TTL=${TTL}" >/dev/null
}

add_record() {
	local ip="$1"
	aliyun_request "AddDomainRecord" "DomainName=${DOMAIN}" "RR=${RR}" "Type=${TYPE}" "Value=${ip}" "TTL=${TTL}" >/dev/null
}

run_once() {
	load_config
	if [ "$ENABLED" != "1" ]; then
		log "Service disabled. Set ${CONFIG}.${CONFIG_SECTION}.enabled=1 to enable."
		return 0
	fi
	if [ -z "$ACCESS_KEY_ID" ] || [ -z "$ACCESS_KEY_SECRET" ] || [ -z "$DOMAIN" ]; then
		log "Missing required configuration: access_key_id, access_key_secret, domain."
		return 1
	fi

	local ip record_info record_id record_value
	ip=$(get_current_ip) || return 1
	record_info=$(get_record_info)
	record_id="${record_info%%|*}"
	record_value="${record_info##*|}"

	if [ -z "$record_id" ]; then
		log "No existing record found, creating new record for ${RR}.${DOMAIN} -> ${ip}"
		add_record "$ip"
		return 0
	fi

	if [ "$record_value" = "$ip" ]; then
		log "Record ${RR}.${DOMAIN} already up to date (${ip})"
		return 0
	fi

	log "Updating record ${RR}.${DOMAIN} from ${record_value} to ${ip}"
	update_record "$record_id" "$ip"
}

run_daemon() {
	while true; do
		run_once || true
		sleep "$INTERVAL"
	done
}

case "${1:-}" in
	--daemon)
		load_config
		run_daemon
		;;
	--once|"" )
		run_once
		;;
	*)
		echo "Usage: $0 [--once|--daemon]" >&2
		exit 1
		;;

esac
