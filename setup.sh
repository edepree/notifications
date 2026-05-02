# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# setup python and ansible environment
uv sync
uv run ansible-galaxy install -r requirements.yml