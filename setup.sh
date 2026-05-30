# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# setup python and ansible environment
uv sync
uv run ansible-galaxy install -r requirements.yml
