#! /bin/bash
set -e -u -o pipefail
# install Poetry to manage Python packages
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
# create a folder for our example Fetch.AI agent
cd ~
mkdir hello-world-fetch
cd hello-world-fetch
# get the example agent script, and run it
wget https://raw.githubusercontent.com/CudoVentures/intercloud-startup-scripts/main/fetchAI/agent.py
# initialise Poetry and install the uagents library from Fetch.AI
/root/.local/bin/poetry init -n
/root/.local/bin/poetry run pip install uagents
