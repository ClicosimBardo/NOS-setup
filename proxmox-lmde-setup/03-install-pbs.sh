#!/bin/bash
# 03-install-pbs.sh
#
# Este script configura os repositórios do Proxmox Backup Server e o instala.
# Nota: Não é comum instalar PVE e PBS no mesmo nó, mas é possível.
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

echo "--- Iniciando a instalação do Proxmox Backup Server para Debian ${DEBIAN_CODENAME} ---"

# --- Adicionar Repositório Proxmox Backup ---
echo "1. Adicionando o repositório Proxmox Backup Server..."

# Garante que a chave GPG exista.
if [ ! -f "/etc/apt/trusted.gpg.d/${PROXMOX_GPG_FILE}" ]; then
    curl -fsSL "https://enterprise.proxmox.com/debian/${PROXMOX_GPG_FILE}" -o "/etc/apt/trusted.gpg.d/${PROXMOX_GPG_FILE}"
    echo "   - Chave GPG do Proxmox adicionada."
fi

# Cria o arquivo do repositório
PBS_REPO_FILE="/etc/apt/sources.list.d/pbs-install-repo.list"
echo "deb http://download.proxmox.com/debian/pbs ${DEBIAN_CODENAME} pbs-no-subscription" > "$PBS_REPO_FILE"
echo "   - Arquivo de repositório '$PBS_REPO_FILE' criado."

echo "2. Atualizando a lista de pacotes..."
apt update

# --- Instalação do Proxmox Backup Server ---
echo "3. Instalando o pacote proxmox-backup-server..."
apt install -y proxmox-backup-server

echo "--- Instalação do Proxmox Backup Server concluída! ---"
echo "Acesse a interface web em https://<seu-ip>:8007"
