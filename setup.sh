#!/bin/bash

# Color definitions for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}       DOCKITT DEPLOYMENT AUTOMATION      ${NC}"
echo -e "${GREEN}==========================================${NC}\n"

# 1. Domain Configuration
read -r -p "Enter domain name for the project [Default: dockitt.local]: " DOMAIN
DOMAIN=${DOMAIN:-dockitt.local}

# 2. Server IP Configuration
DETECTED_IP=$(hostname -I | awk '{print $1}')
if [ -z "$DETECTED_IP" ]; then
    DETECTED_IP=$(ip -4 route get 8.8.8.8 | awk '{print $7}' | tr -d '\n')
fi

read -r -p "Confirm Server IP [Default: $DETECTED_IP]: " SERVER_IP
SERVER_IP=${SERVER_IP:-$DETECTED_IP}

echo -e "\n${CYAN}[+] Current Configuration:${NC}"
echo -e "  - Domain: ${YELLOW}$DOMAIN${NC}"
echo -e "  - Server IP: ${YELLOW}$SERVER_IP${NC}\n"

# Helper function for Yes/No prompts
ask_yes_no() {
    while true; do
        read -r -p "$1 [Y/n]: " yn
        case $yn in
            [Yy]* | "" ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please enter Y (Yes) or n (No).";;
        esac
    done
}

# Step 0: Prepare Environment Variables
echo -e "${CYAN}--- Step 0: Preparing Environment Variables ---${NC}"
if [ ! -f ".env.example.conf" ]; then
    echo -e "${RED}Error: .env.example.conf not found in the root directory!${NC}"
    echo "Please ensure the file exists before running this script."
    exit 1
fi

echo "Generating global .env file..."
cp .env.example.conf .env

# Auto-detect current User ID and Group ID
CURRENT_PUID=$(id -u)
CURRENT_PGID=$(id -g)

# Update values in the global .env using sed
sed -i "s|PUID=1000|PUID=${CURRENT_PUID}|g" .env
sed -i "s|PGID=1000|PGID=${CURRENT_PGID}|g" .env
sed -i "s|git.yourdomain.com|git.${DOMAIN}|g" .env
sed -i "s|ci.yourdomain.com|drone.${DOMAIN}|g" .env
sed -i "s|docs.yourdomain.com|docs.${DOMAIN}|g" .env

# Generate a random 16-hex string for DRONE_RPC_SECRET
DRONE_SECRET=$(openssl rand -hex 16 2>/dev/null || echo "random_secret_$(date +%s)")
sed -i "s|thay_doi_chuoi_bi_mat_rpc_nay|${DRONE_SECRET}|g" .env

echo -e "${GREEN}Global .env file generated successfully.${NC}"

# Distribute .env to all directories containing a docker-compose.yml
echo "Distributing .env to service directories..."
for dir in */; do
    if [ -f "${dir}docker-compose.yml" ]; then
        cp .env "${dir}.env"
        echo -e "  -> Copied to ${YELLOW}${dir}.env${NC}"
    fi
done
echo ""

# Step 1: Create Docker Network
echo -e "${CYAN}--- Step 1: Initialize Docker Network ---${NC}"
if docker network inspect dockitt_network >/dev/null 2>&1; then
    echo -e "${YELLOW}Network 'dockitt_network' already exists. Skipping...${NC}"
else
    echo "Creating dockitt_network..."
    docker network create --subnet=10.0.0.0/24 --gateway=10.0.0.1 dockitt_network
fi
echo ""

# Step 2 & 3: DNSMasq
if ask_yes_no "Do you want to deploy DNSMasq?"; then
    echo "Configuring dnsmasq.conf..."
    if [ -f "dnsmasq/dnsmasq.conf" ]; then
        if grep -q "^address=/" dnsmasq/dnsmasq.conf; then
            sed -i "s|^address=/.*|address=/.${DOMAIN}/${SERVER_IP}|g" dnsmasq/dnsmasq.conf
        else
            echo "address=/.${DOMAIN}/${SERVER_IP}" >> dnsmasq/dnsmasq.conf
        fi
        echo -e "${GREEN}Successfully updated dnsmasq.conf -> address=/.${DOMAIN}/${SERVER_IP}${NC}"
    else
        echo -e "${RED}Error: dnsmasq/dnsmasq.conf not found!${NC}"
    fi

    echo "Starting DNSMasq..."
    cd dnsmasq && docker compose up -d && cd ..
fi
echo ""

# Step 4 & 5: Nginx Proxy Manager (NPM)
if ask_yes_no "Do you want to deploy Nginx Proxy Manager (NPM)?"; then
    echo "Starting NPM..."
    cd npm && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED]:${NC}"
    echo -e "  1. Open ${CYAN}http://$SERVER_IP:81${NC}"
    echo -e "  2. Login with default credentials and create an admin account."
fi
echo ""

# Step 6 & 7: IT-Tools
if ask_yes_no "Do you want to deploy IT-Tools?"; then
    echo "Starting IT-Tools..."
    cd it-tools && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for IT-Tools:${NC}"
    echo -e "  - Domain Names: ${CYAN}tools.$DOMAIN${NC}"
    echo -e "  - Scheme: http"
    echo -e "  - Forward Hostname/IP: ${CYAN}it-tools${NC}"
    echo -e "  - Forward Port: ${CYAN}80${NC}"
    echo -e "  - Check: Block Common Exploits"
fi
echo ""

# Step 8 -> 10: Gitea
if ask_yes_no "Do you want to deploy Gitea?"; then
    echo "Starting Gitea..."
    cd gitea && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for Gitea:${NC}"
    echo -e "  - Domain Names: ${CYAN}git.$DOMAIN${NC}"
    echo -e "  - Forward Hostname/IP: ${CYAN}gitea${NC}"
    echo -e "  - Forward Port: ${CYAN}3000${NC}"
    echo -e "  - ${GREEN}Open http://git.$DOMAIN/ and create an admin account.${NC}"
fi
echo ""

# Step 11 -> 16: Drone
if ask_yes_no "Do you want to deploy Drone?"; then
    echo -e "${RED}[IMPORTANT]${NC} Drone requires an OAuth2 application on Gitea first!"
    echo -e "  1. Go to Gitea and create an OAuth2 Application for Drone."
    echo -e "  2. Edit ${CYAN}drone/.env${NC} and update DRONE_GITEA_CLIENT_ID and DRONE_GITEA_CLIENT_SECRET."

    if ask_yes_no "Have you configured the ClientID and ClientSecret in drone/.env?"; then
        echo "Starting Drone..."
        cd drone && docker compose up -d && cd ..
        echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for Drone:${NC}"
        echo -e "  - Domain Names: ${CYAN}drone.$DOMAIN${NC}"
        echo -e "  - Forward Hostname/IP: ${CYAN}drone${NC}"
        echo -e "  - Forward Port: ${CYAN}80${NC}"
        echo -e "  - ${GREEN}Open http://drone.$DOMAIN/, authorize on Gitea, and register.${NC}"
    else
        echo -e "${YELLOW}Skipping Drone. Please configure OAuth2 and run 'docker compose up -d' in the drone folder later.${NC}"
    fi
fi
echo ""

# Step 17 -> 19: BookStack
if ask_yes_no "Do you want to deploy BookStack?"; then
    echo "Starting BookStack..."
    cd bookstack && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for BookStack:${NC}"
    echo -e "  - Domain Names: ${CYAN}docs.$DOMAIN${NC}"
    echo -e "  - Forward Hostname/IP: ${CYAN}bookstack${NC}"
    echo -e "  - Forward Port: ${CYAN}80${NC}"
    echo -e "  - ${GREEN}Access: http://docs.$DOMAIN/${NC}"
fi
echo ""

# Step 20 -> 22: Adminer
if ask_yes_no "Do you want to deploy Adminer?"; then
    echo "Starting Adminer..."
    cd adminer && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for Adminer:${NC}"
    echo -e "  - Domain Names: ${CYAN}db.$DOMAIN${NC}"
    echo -e "  - Forward Hostname/IP: ${CYAN}adminer${NC}"
    echo -e "  - Forward Port: ${CYAN}8080${NC}"
    echo -e "  - ${GREEN}Access: http://db.$DOMAIN/${NC}"
fi
echo ""

# Step 23 -> 25: Uptime-Kuma
if ask_yes_no "Do you want to deploy Uptime-Kuma?"; then
    echo "Starting Uptime-Kuma..."
    cd uptime-kuma && docker compose up -d && cd ..
    echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for Uptime-Kuma:${NC}"
    echo -e "  - Domain Names: ${CYAN}status.$DOMAIN${NC}"
    echo -e "  - Forward Hostname/IP: ${CYAN}uptime-kuma${NC}"
    echo -e "  - Forward Port: ${CYAN}3001${NC}"
    echo -e "  - ${GREEN}Access: http://status.$DOMAIN/${NC}"
fi
echo ""

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}           DEPLOYMENT COMPLETED           ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "${RED}[GENERAL STEP - MANDATORY]${NC}"
echo -e "All computers wishing to access the system must have their DNS configured to point to the Server IP: ${YELLOW}$SERVER_IP${NC} (Step 26)."
