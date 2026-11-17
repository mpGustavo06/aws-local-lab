#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
TERRAFORM_DIR="${SCRIPT_DIR}/terraform"

if [ ! -f "${ENV_FILE}" ]; then
  echo "Erro: Arquivo .env não encontrado em ${ENV_FILE}."
  exit 1
fi

set -a
source <(tr -d '\r' < "${ENV_FILE}")
set +a

cd "${TERRAFORM_DIR}"

if [ $# -eq 0 ]; then
  echo "Uso: ./env-emulator.sh <comando> [opções]"
  echo "Exemplo: ./env-emulator.sh apply -auto-approve"
  exit 1
fi

terraform "$@"