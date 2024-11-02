# MicroHobby XONSH Profile

This is the xonsh profile that I use. Here are some instructions of which pip packages you need to install:

```bash
pip install 'xonsh[full]' --break-system-packages
pip install python-lsp-server --break-system-packages
pip install gitpython --break-system-packages
pip install xontrib-powerline2 --break-system-packages
pip install psutil --break-system-packages
```
On more modern systems the powerline from pip is not working as expected, so you can install it but copy the modified from here:

```bash
cp ./patches/powerline2.py ~/.local/lib/python3.11/site-packages/xontrib/powerline2.xsh
```
Remember that the Python version may change, so you need to adapt the path to the correct one.
