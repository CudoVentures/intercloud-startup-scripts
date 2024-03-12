#!/bin/bash

# ******************************************************************************
# This script automates the process of setting up and environment for Archway 
# and creating an Archway account.
# ******************************************************************************

# Create a new Archway account and capture the address
create_archway_account() {
    echo "Creating new Archway account..."
    output=$(archway accounts new mywallet --keyring-backend test)
    address=$(echo "$output" | grep 'Address:' | awk '{print $2}')
    echo "$output"
    echo $address > account_address.txt
}

# Update os
sudo apt update

# Install go
echo "Installing go..."
sudo apt install -y golang-go

# Install curl to install node v18
sudo apt install -y curl

# Install jq
echo "Installing jq..."
sudo apt install -y jq

# Install cargo
echo "Installing cargo..."
#curl https://sh.rustup.rs -sSf | sh
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Install cargo generate
#cargo add cargo-generate
echo "Installing cargo-generate..."
yes | cargo install cargo-generate

# Install docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install nodejs 18
echo "Installing nodejs..."
#curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#sudo apt install -y nodejs
nvm install --lts
nvm use --lts

# Install npm
echo "Installing npm..."
sudo apt install -y npm

echo "Installing Archway Developer CLI..."
npm install -g @archwayhq/cli

# Configure Archway CLI
echo "Configuring Archway Developer CLI to use the Constantine network..."
#archway config chain-id constantine-3 --global
archway config set -g chain-id constantine-3
# archway config chain-id archway-1 --global  # For Mainnet

# Set keyring backend to test
archway config set -g keyring-backend test

echo "Current Archway CLI configuration:"
archway config show

# Preparing accounts
#echo "Creating a new Archway account..."
#archway accounts new mywallet
create_archway_account

echo "Listing all accounts..."
archway accounts list --keyring-backend test

# Clone MultiSig repository
#echo "Change to user's home directory..."
#cd ~
echo "Cloning MultiSig repository..."
git clone https://github.com/archway-network/archway-msig.git
echo "Change into the archway-msig directory..."
cd archway-msig
echo "Install packages with npm..."
npm install