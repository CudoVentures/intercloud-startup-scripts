#!/bin/bash

# ******************************************************************************
# This script deploys the Archway MultiSig to the Constantine testnet and 
# starts a local frontend to interact with the MultiSig. It automates the 
# process of setting up the environment, creating an Archway account, 
# configuring the MultiSig parameters, deploying the contracts, and setting up 
# the local development server.
# ******************************************************************************

# Create a new Archway account and capture the address
create_archway_account() {
    echo "Creating new Archway account..."
    output=$(archway accounts new mywallet)
    address=$(echo "$output" | grep 'Address:' | awk '{print $2}')
    echo "$output"
    echo $address > account_address.txt
}

# Configure the multisig_params.json file
configure_multisig_script() {
    echo "Configuring MultiSig script..."
    account_address=$(<account_address.txt)
    jq --arg address "$account_address" '.sender_account = $address | .members = [{addr: $address, weight: 1}]' scripts/instantiate/multisig_params.json > tmp.$$.json && mv tmp.$$.json scripts/instantiate/multisig_params.json
}

# Update the .env file
setup_env_file() {
    echo "Setting up .env file..."
    cp .env.example .env
    sed -i 's/RUNTIME_ENVIRONMENT=mainnet|testnet|titus/RUNTIME_ENVIRONMENT=testnet/' .env
    contracts=$(cat scripts/instantiate/multisig_contracts_result.json)
    echo "DAODAO_CONTRACTS=$contracts" >> .env
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
curl https://sh.rustup.rs -sSf | sh

# Install cargo generate
cargo add cargo-generate

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

# Install gnome keyring
sudo apt-get install -y gnome-keyring
echo 'somecredstorepass' | gnome-keyring-daemon --unlock # unlock the system's keyring

# Install nodejs 18
echo "Installing nodejs..."
#curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#sudo apt install -y nodejs
nvm install 18
nvm use 18

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
archway accounts list

# Clone MultiSig repository
echo "Change to user's home directory..."
cd ~
echo "Cloning MultiSig repository..."
git clone git@github.com:archway-network/archway-msig.git
cd archway-msig
npm install

# Configuring MultiSig script
configure_multisig_script

# Deploy the MultiSig contracts
echo "Deploying MultiSig contracts..."
bash scripts/instantiate/instantiate_contracts.sh

# Set up MultiSig environment
#echo "Setting up MultiSig environment..."
#cp .env.example .env
setup_env_file

# Step 8: Launching the development server
echo "Launching the development server..."
npm run dev
