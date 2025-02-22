#!/bin/bash

echo "SETUP ENVIRONMENT FOR XONSH"
echo "NEEDS SUPER USER PRIVILEGIES 🐮"
sudo echo "OK"

# install python3 and pip3 from Debian packages
sudo apt update
sudo apt install -y \
    python3 \
    python3-pip \
    python3-setuptools \
    pipx

# install the gh cli
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y


gh auth login

# install copilot (propably this will fail wihout the login)
gh extension install github/gh-copilot


# install xonsh from pip
pipx install xonsh
pipx inject xonsh psutil
pipx inject xonsh distro
pipx inject xonsh shtab
pipx inject xonsh pyyaml
pipx inject xonsh GitPython
pipx inject xonsh xontrib-powerline2
pipx inject xonsh python-lsp-server
pipx inject xonsh pylsp-rope
pipx inject xonsh blessed
pipx inject xonsh pygments
pipx inject xonsh setproctitle
pipx inject xonsh prompt-toolkit
# FIXME: mypy is not working with xonsh
# pipx inject xonsh pylsp-mypy

# apply the patches
cp ./patches/powerline2.xsh $HOME/.local/share/pipx/venvs/xonsh/lib/python3.11/site-packages/xontrib/powerline2.xsh
cp ./patches/powerline2.xsh $HOME/.local/share/pipx/venvs/xonsh/lib/python3.12/site-packages/xontrib/powerline2.xsh

echo "To develop xonsh scripts with VS Code add the:"
echo '"pylsp.executable": "$HOME/.local/pipx/venvs/xonsh/bin/pylsp"'
