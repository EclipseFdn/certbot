#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
DOMAINS="${1}"

read -r -d '' PROG <<EOF || :
local certbot = import "${SCRIPT_FOLDER}/certbot.libsonnet";
local certs = import "${DOMAINS}";
std.manifestYamlStream(certbot.newCertbotDeployment(certs), false, false)
EOF
jsonnet -S -e "${PROG}"
