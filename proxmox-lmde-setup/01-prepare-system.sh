#!/bin/bash
# 01-prepare-system.sh
#
# Este script prepara o sistema LMDE para a instalação do Proxmox.
# 1. Altera a identificação do sistema de LMDE para Debian.
# 2. Configura o arquivo /etc/hosts.
# 3. Converte os repositórios do LMDE para os repositórios Debian.
#
# IMPORTANTE: Execute como root ou com sudo.

set -e

# --- Variáveis de Versão (Ajuste aqui para futuras versões) ---
# Versão do LMDE de origem
LMDE_PRETTY_NAME="LMDE 7 (gigi)"
LMDE_VERSION_ID="7"
LMDE_CODENAME="gigi"

# Versão do Debian de destino
DEBIAN_NAME="Debian GNU/Linux"
DEBIAN_PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
DEBIAN_VERSION_ID="13"
DEBIAN_CODENAME="trixie"


# --- Verificação de Root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root. Use sudo." >&2
  exit 1
fi

echo "--- Iniciando a preparação do sistema para o Proxmox ---"
echo "AVISO: O alvo é o Debian 13 'trixie', que é uma versão de TESTES."
read -p "Tem certeza que deseja continuar? (s/N): " choice
if [[ ! "$choice" =~ ^[SsYy]$ ]]; then
    echo "Operação cancelada."
    exit 1
fi

# --- Backup e Modificação do /etc/os-release ---
echo "1. Alterando a identificação do sistema para Debian..."
if [ -f /etc/os-release ]; then
    cp /etc/os-release /etc/os-release.bak
    echo "   - Backup de /etc/os-release criado em /etc/os-release.bak"
    # Transforma LMDE em Debian.
    sed -i 's/NAME="Linux Mint"/NAME="'"$DEBIAN_NAME"'"/' /etc/os-release
    sed -i 's/ID=linuxmint/ID=debian/' /etc/os-release
    sed -i 's/PRETTY_NAME=".*"/PRETTY_NAME="'"$DEBIAN_PRETTY_NAME"'"/' /etc/os-release
    sed -i 's/VERSION_ID=".*"/VERSION_ID="'"$DEBIAN_VERSION_ID"'"/' /etc/os-release
    sed -i 's/VERSION_CODENAME=.*/VERSION_CODENAME='"$DEBIAN_CODENAME"'/' /etc/os-release
    sed -i '/MINT_ID/d' /etc/os-release
    sed -i '/DEBIAN_FRONTEND/d' /etc/os-release
    echo "   - /etc/os-release atualizado para Debian $DEBIAN_VERSION_ID ($DEBIAN_CODENAME)."
else
    echo "AVISO: /etc/os-release não encontrado. Pulando etapa."
fi


# --- Backup e Modificação do /etc/hosts ---
echo "2. Configurando /etc/hosts..."
IP_ADDRESS=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)
cp /etc/hosts /etc/hosts.bak
echo "   - Backup de /etc/hosts criado em /etc/hosts.bak"

# Remove entradas antigas do próprio hostname para evitar duplicatas
sed -i "/$HOSTNAME/d" /etc/hosts

# Adiciona a entrada correta
cat <<EOF >> /etc/hosts
$IP_ADDRESS $HOSTNAME.proxmox $HOSTNAME
EOF

echo "   - /etc/hosts atualizado."

# --- Configuração dos Repositórios Debian ---
echo "3. Configurando repositórios para Debian 13 (trixie)..."
# Remove todos os repositórios antigos do Mint/LMDE
mkdir -p /etc/apt/sources.list.d.bak
mv /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d.bak/ 2>/dev/null || true
echo "   - Repositórios antigos movidos para /etc/apt/sources.list.d.bak/"

# Cria novo arquivo de sources list para Debian
cat <<EOF > /etc/apt/sources.list
# Repositórios Debian 13 (trixie)
deb http://deb.debian.org/debian/ trixie main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free-firmware

# Repositórios de segurança (ainda não disponível para trixie, apontando para trixie-security)
deb http://security.debian.org/debian-security trixie-security main contrib non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free-firmware

# Repositórios de atualizações (updates)
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free-firmware
EOF
echo "   - /etc/apt/sources.list configurado para Debian Trixie."

# --- Atualização do Sistema ---
echo "4. Atualizando a lista de pacotes e o sistema..."
apt update
apt-get dist-upgrade -y

echo "--- Preparação do sistema concluída com sucesso! ---"
echo "É recomendado reiniciar o sistema antes de prosseguir."
