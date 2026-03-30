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
# Attempt to automatically detect the server IP
DETECTED_IP=$(hostname -I | awk '{print $1}')
if [ -z "$DETECTED_IP" ]; then
    DETECTED_IP=$(ip -4 route get 8.8.8.8 | awk '{print $7}' | tr -d '\n')
fi

read -r -p "Confirm Server IP[Default: $DETECTED_IP]: " SERVER_IP
SERVER_IP=${SERVER_IP:-$DETECTED_IP}

echo -e "\n${CYAN}[+] Current Configuration:${NC}"
echo -e "  - Domain: ${YELLOW}$DOMAIN${NC}"
echo -e "  - Server IP: ${YELLOW}$SERVER_IP${NC}\n"

# Helper function for Yes/No prompts
ask_yes_no() {
    while true; do
        read -r -p "$1 [Y/n]: " yn
        case $yn in [Yy]* | "" ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please enter Y (Yes) or n (No).";;
        esac
    done
}

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
        # Update or append the address line
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
    echo -e "  - Forward Hostname/IP: ${CYAN}gitea${NC} (Verify container_name)"
    echo -e "  - Forward Port: ${CYAN}3000${NC}"
    echo -e "  - ${GREEN}Open http://git.$DOMAIN/ and create an admin account.${NC}"
fi
echo ""

# Step 11 -> 16: Drone
if ask_yes_no "Do you want to deploy Drone?"; then
    echo -e "${RED}[IMPORTANT]${NC} Drone requires an OAuth2 application on Gitea first!"
    echo -e "  1. Go to Gitea and create an OAuth2 Application for Drone."
    echo -e "  2. Edit ${CYAN}drone/docker-compose.yml${NC} and insert your ClientID & ClientSecret."

    if ask_yes_no "Have you configured ClientID and ClientSecret in Drone's docker-compose.yml?"; then
        echo "Starting Drone..."
        cd drone && docker compose up -d && cd ..
        echo -e "${YELLOW}>> [MANUAL ACTION REQUIRED] Configure NPM Proxy for Drone:${NC}"
        echo -e "  - Domain Names: ${CYAN}drone.$DOMAIN${NC}"
        echo -e "  - Forward Hostname/IP: ${CYAN}drone${NC}"
        echo -e "  - Forward Port: ${CYAN}80${NC}"
        echo -e "  - ${GREEN}Open http://drone.$DOMAIN/, authorize on Gitea, and register.${NC}"
    else
        echo -e "${YELLOW}Skipping Drone. Please configure OAuth2 and run the script again later.${NC}"
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
