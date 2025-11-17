#!/bin/bash
# 02-install-pve.sh
#
# Este script configura os repositórios do Proxmox VE e instala os pacotes.
#
# IMPORTANTE: Execute como root ou com sudo.

set -e

# --- Variáveis de Versão ---
DEBIAN_CODENAME="trixie"
PROXMOX_GPG_FILE="proxmox-release-${DEBIAN_CODENAME}.gpg"

# --- Verificação de Root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root. Use sudo." >&2
  exit 1
fi

echo "--- Iniciando a instalação do Proxmox VE para Debian ${DEBIAN_CODENAME} ---"
echo "AVISO: Esta é uma instalação não-padrão e pode falhar se os repositórios Proxmox para '${DEBIAN_CODENAME}' não existirem."

# --- Adicionar Repositório Proxmox VE ---
echo "1. Adicionando o repositório Proxmox VE..."

# Adiciona a chave GPG
curl -fsSL "https://enterprise.proxmox.com/debian/${PROXMOX_GPG_FILE}" -o "/etc/apt/trusted.gpg.d/${PROXMOX_GPG_FILE}"
echo "   - Chave GPG do Proxmox adicionada."

# Cria o arquivo do repositório
PVE_REPO_FILE="/etc/apt/sources.list.d/pve-install-repo.list"
echo "deb http://download.proxmox.com/debian/pve ${DEBIAN_CODENAME} pve-no-subscription" > "$PVE_REPO_FILE"
echo "   - Arquivo de repositório '$PVE_REPO_FILE' criado."

echo "2. Atualizando a lista de pacotes..."
apt update

# --- Instalação do Proxmox VE ---
echo "3. Instalando Proxmox VE, postfix e open-iscsi..."
# O "DEBIAN_FRONTEND=noninteractive" evita perguntas durante a instalação do postfix
DEBIAN_FRONTEND=noninteractive apt install -y proxmox-ve postfix open-iscsi

# --- Limpeza ---
echo "4. Removendo pacotes conflitantes..."
# O os-prober pode causar problemas em sistemas com Proxmox
apt remove -y os-prober

echo "--- Instalação do Proxmox VE concluída! ---"
echo "Após a reconfiguração da rede, reinicie o sistema e acesse a interface web em https://<seu-ip>:8006"
