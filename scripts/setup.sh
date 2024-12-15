#!/bin/bash

echo "SETUP ENVIRONMENT FOR XONSH"
echo "NEEDS SUPER USER PRIVILEGIES 🐮"
sudo echo "OK"

# install python3 and pip3 from Debian packages
sudo apt update
sudo apt install -y \
    python3 \
    python3-pip \
    python3-setuptools

# install xonsh from pip
pipx install xonsh
pipx inject xonsh psutil
pipx inject xonsh GitPython
pipx inject xonsh xontrib-powerline2
pipx inject xonsh python-lsp-server
pipx inject xonsh pylsp-rope
# FIXME: mypy is not working with xonsh
# pipx inject xonsh pylsp-mypy

# apply the patches
cp ./patches/powerline2.xsh $HOME/.local/pipx/venvs/xonsh/lib/python3.11/site-packages/xontrib/powerline2.xsh

echo "To develop xonsh scripts with VS Code add the:"
echo '"pylsp.executable": "$HOME/.local/pipx/venvs/xonsh/bin/pylsp"'
