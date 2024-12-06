# XONSH WIZARD START
print("loading xonsh foreign shell")
# XONSH WIZARD END

$XONSH_SHOW_TRACEBACK = True

import os
import time
import socket
import getpass
import random
import platform
import psutil
import enum
import json

from git import Repo

____username = getpass.getuser()

ERROR_EMOJI = [
    " 󰇸 ",
    "  ",
    "  ",
    "  ",
    " 󰫜 ",
    "  ",
    "  ",
    "  ",
    " 󱅧 ",
    " 󰱭 ",
    " 󰯈 ",
    " 󰱵 ",
    "  ",
    " 󰻖 ",
    " 󱕽 "
]

os.environ["CASTELLO_SERVER"] = "192.168.0.39"
os.environ["DROPLET_IP"] = "143.198.182.128"
os.environ["AWS_SERVER"] = "ec2-3-133-114-116.us-east-2.compute.amazonaws.com"
os.environ["HOSTNAME"] = socket.gethostname()

# ------------------------------------------------------------------------ utils

class Color(enum.Enum):
    BLACK = 30
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36
    WHITE = 37

class BgColor(enum.Enum):
    BLACK = 40
    RED = 41
    GREEN = 42
    YELLOW = 43
    BLUE = 44
    MAGENTA = 45
    CYAN = 46
    WHITE = 47

def _printc(text, color, bgcolor=None):
    if bgcolor == None:
        print(f"\033[{color.value}m{text}\033[0m")
    else:
        print(f"\033[{color.value};{bgcolor.value}m{text}\033[0m")


# ------------------------------------------------------------------------ utils

# -------------------------------------------------------------------- functions
def find_git_root(start_path):
    current_path = start_path
    while current_path != os.path.dirname(current_path):  # Stop at root directory
        if os.path.isdir(os.path.join(current_path, '.git')):
            return current_path
        current_path = os.path.dirname(current_path)
    return None

def _git_hash():
    try:
        git_root = find_git_root(os.getcwd())

        if git_root == None:
            return None

        repo = Repo(git_root)
        return repo.head.commit.hexsha[:7]
    except:
        return None

def _git_summary():
    try:
        git_root = find_git_root(os.getcwd())

        if git_root == None:
            return None

        repo = Repo(git_root)
        return repo.head.commit.summary[:80]
    except:
        return None

def _git_status():
    try:
        git_root = find_git_root(os.getcwd())

        if git_root == None:
            return None

        repo = Repo(git_root)
        return len(repo.index.diff(None))
    except:
        return None

def _git_branch():
    try:
        git_root = find_git_root(os.getcwd())

        if git_root == None:
            return None

        repo = Repo(git_root)
        return repo.active_branch
    except:
        return None

# return only the two last directories
def _only_last_dirs():
    cwd = os.getcwd()
    dirs = cwd.split("/")
    if len(dirs) > 2:
        return f"{dirs[-2]}/{dirs[-1]}"
    return cwd

# return an emoji error if the last command failed
def _last_command_failed():
    # get a random emoji
    emoj = random.choice(ERROR_EMOJI)

    if __xonsh__.last.rtn != 0:
        return f" {emoj} "
    return None

def __get_process_name_load_more_than_20pc():
    for proc in psutil.process_iter():
        try:
            if proc.cpu_percent() > 20:
                return proc.name()
        except:
            return None
    return None

def _get_git_signing_key():
    try:
        git_root = find_git_root(os.getcwd())

        if git_root == None:
            return None

        repo = Repo(git_root)
        config_reader = repo.config_reader()
        signing_key = config_reader.get_value('user', 'signingkey', default=None)

        if signing_key == "9E8404E08DA8ED75":
            return "matheus.castello@toradex.com"
        else:
            return "matheus@castello.eng.br"

    except Exception:
        return None

def _gtck(args):
    actual_key = $(git config --global user.signingKey).strip()

    if actual_key == "9E8404E08DA8ED75":
        print("Setting key for matheus@castello.eng.br")
        $(git config --global user.email "matheus@castello.eng.br")
        $(git config --global user.name "Matheus Castello")
        $(git config --global user.signingkey '7CB84B1084E5AA77')
    else:
        SIGN_EMAIL = "matheus.castello@toradex.com"
        print("Setting key for matheus.castello@toradex.com")
        $(git config --global user.email "matheus.castello@toradex.com")
        $(git config --global user.name "Matheus Castello")
        $(git config --global user.signingkey '9E8404E08DA8ED75')

aliases['gtck'] = _gtck

# git commands
aliases['gtc'] = 'git commit -vs'
aliases['gts'] = 'git status'
aliases['gtd'] = 'git diff'
aliases['gta'] = 'git add'
aliases['gtca'] = 'git commit --amend'
aliases['gtr'] = 'git remote -v'
aliases['gtl'] = 'git log'
aliases['gtlo'] = 'git log --oneline'

def _gtpo(args):
    git_root = find_git_root(os.getcwd())

    if git_root == None:
        print("Not a git repository")
        return None

    repo = Repo(git_root)
    branch = repo.active_branch.name

    if len(args) == 0:
        $(git push origin @(branch))
    else:
        s_args = " ".join(args)
        $(git push origin @(branch) @(s_args))

aliases['gtpo'] = _gtpo
aliases['gtp'] = 'git push'
aliases['gtrs'] = 'git checkout HEAD --'
aliases['gtcp'] = 'git cherry-pick'
aliases['gtcb'] = 'git checkout -b'
aliases['gtb'] = 'git checkout -b'
aliases['gtba'] = 'git branch -a'

def _gtbd(args):
    branch = args[0]
    $(git branch -d @(branch))
    $(git push origin --delete @(branch))

aliases['gtbd'] = _gtbd
aliases['gtrb'] = 'git rebase -i HEAD~'
aliases['gtrbc'] = 'git rebase --continue'
aliases['gtrba'] = 'git rebase --abort'
aliases['gtff'] = 'git fetch fork'
aliases['gtfo'] = 'git fetch origin'
aliases['gti'] = 'git init'

aliases['gtck'] = _gtck

aliases['c'] = 'clear'
aliases['ls'] = 'ls -lah --color=auto -v'
aliases['l'] = '/usr/bin/ls --color=auto -v'

# interop workaround for explorer
def __explorer(args):
    cmd = f'explorer.exe {" ".join(args)}'
    $(bash -c @(cmd))

aliases['explorer'] = __explorer

# connections

def __connect_to_server():
    if __xonsh__.env.get('WSL_DISTRO_NAME'):
        print("OPENING VS CODE")
        # set the dir to the windows path
        os.chdir("/mnt/c/Users/mpro3")
        cmd = f'cmd.exe /C code --remote ssh-remote+{os.environ["CASTELLO_SERVER"]}'
        $(bash -c @(cmd))
        print("VS CODE")
        time.sleep(3)
        cmd = f'ssh -X castello@{os.environ["CASTELLO_SERVER"]}'
        bash -c @(cmd)

aliases['connect-to-server'] = __connect_to_server

def __connect_to_droplet():
    cmd = f'ssh root@{os.environ["DROPLET_IP"]}'
    !(bash -c @(cmd))

aliases['connect-to-droplet'] = __connect_to_droplet

def __copy_from_droplet(args):
    args = f'{" ".join(args)}'
    cmd = f'scp root@{os.environ["DROPLET_IP"]}:{args} .'
    $(bash -c @(cmd))

aliases['copy-from-droplet'] = __copy_from_droplet

def __copy_to_droplet(args):
    args = f'{" ".join(args)}'
    cmd = f'scp -r {args} root@{os.environ["DROPLET_IP"]}:/home/microhobby'
    $(bash -c @(cmd))

aliases['copy-to-droplet'] = __copy_to_droplet

def __connect_to_aws():
    !(ssh -i "/home/microhobby/.ssh/telemetryKeys.pem" "ubuntu@$AWS_SERVER")

aliases['connect-to-aws'] = __connect_to_aws

def __copy_from_aws(args):
    args = f'{" ".join(args)}'
    cmd = f'scp -i "/home/microhobby/.ssh/telemetryKeys.pem" "ubuntu@$AWS_SERVER:{args}" .'
    $(bash -c @(cmd))

aliases['copy-from-aws'] = __copy_from_aws


def __recur_registry_search(namespace, results=None, next_page=-1):
    if results is None:
        results = []

    if next_page == -1:
        data = $(curl -s f"https://registry.hub.docker.com/v2/repositories/{namespace}?page_size=100")
    elif next_page is not None:
        data = $(curl -s @(next_page))

    data_json = json.loads(data)

    if 'results' in data_json:
        results.extend(data_json['results'])

    if data_json.get('next') is None:
        return results
    else:
        return __recur_registry_search(namespace, results, data_json['next'])


def __recur_tag_search(namespace, image, results=None, next_page=-1):
    if results is None:
        results = []

    if next_page == -1:
        data = $(curl -s f"https://registry.hub.docker.com/v2/repositories/{namespace}/{image}/tags/?page_size=100")
    elif next_page is not None:
        data = $(curl -s @(next_page))

    data_json = json.loads(data)

    if 'results' in data_json:
        results.extend(data_json['results'])

    if data_json.get('next') is None:
        return results
    else:
        return __recur_tag_search(namespace, image, results, data_json['next'])

def __dict_to_string(d):
    return ', '.join(f"{key}: {value}" for key, value in d.items())


def __dockersearch(args):
    if len(args) < 2:
        print("Usage: docker-search <namespace> <image> <tag>")
        return

    namespace = args[0]
    image = args[1]
    tag = None

    if len(args) == 3:
        tag = args[2]
        print(f"Searching for {namespace}/{image}:{tag} images")
    else:
        print(f"Searching for {namespace}/{image} images")

    results = __recur_registry_search(namespace)

    if len(results) == 0:
        print("No results found")
        return

    _find = 0

    for result in results:
        if result['name'] and isinstance(result['name'], str) and image == result['name']:
                tags = __recur_tag_search(namespace, result['name'])

                for _tag in tags:
                    if tag is not None and tag != _tag['name']:
                        continue

                    _find += 1

                    _printc("{", Color.RED)

                    _printc(f"\tNAME={result['name']}", Color.GREEN)
                    _printc(f"\tTAG={_tag['name']}", Color.CYAN)

                    _printc("\t{", Color.GREEN)

                    for _image in _tag['images']:
                        _printc(f"\t\tARCH={_image['architecture']}", Color.MAGENTA)

                    _printc("\t}", Color.GREEN)
                    _printc("}", Color.RED)

    if _find == 0:
        _printc("No results found", Color.RED)


aliases['docker-search'] = __dockersearch


# -------------------------------------------------------------------- functions

# -------------------------------------------------------------------- path

$_ORIGINAL_PATH = $PATH[:]
[$PATH.remove(path) for path in $PATH.paths if path.startswith("/mnt/c/")]

# vs code
if os.environ["HOSTNAME"] != "server":
    ____code = "/mnt/c/Users/mpro3/AppData/Local/Programs/Microsoft VS Code/bin/code"
    ____code_dir = $(dirname @(____code))
    $PATH.insert(0, ____code_dir)

# explorer
if os.environ["HOSTNAME"] != "server":
    ____programto = "/mnt/c/Windows/explorer.exe"
    ____programto_dir = $(dirname @(____programto))
    $PATH.insert(0, ____programto_dir)

# cmd.exe
if os.environ["HOSTNAME"] != "server":
    if not os.path.exists("/usr/local/bin/cmd.exe"):
        print("Creating symlink for cmd.exe")
        print("You need to run this as administrator")
        $(sudo ln -s /mnt/c/Windows/System32/cmd.exe /usr/local/bin/cmd.exe)

# ipconfig.exe
if os.environ["HOSTNAME"] != "server":
    ____programto = "/mnt/c/Windows/System32/ipconfig.exe"
    ____programto_dir = $(dirname @(____programto))
    $PATH.insert(0, ____programto_dir)

# powershell.exe
if os.environ["HOSTNAME"] != "server":
    ____programto = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    ____programto_dir = $(dirname @(____programto))
    $PATH.insert(0, ____programto_dir)

# -------------------------------------------------------------------- path

# -------------------------------------------------------------------- powerline

$PL_EXTRA_SEC = {
    "user": lambda: [
                    f"   {____username} ",
                    "#ffffff",
                    "#4e006d"
                ],
    "git_summary": lambda: [
                    f" 󰜛 {_git_summary()} ",
                    "#002f64",
                    "#ffffff"
                ] if _git_hash() else None,
    "git_hash": lambda: [
                    f"  {_git_hash()} ",
                    "#ffffff",
                    "#002f64"
                ] if _git_hash() else None,
    "cwd": lambda: [
                    f" {_only_last_dirs()} ",
                    "#ffffff",
                    "#0078ce"
                ],
    "error": lambda: [
                    " 󰩐 ",
                    "#ffffff",
                    "#035500"
                ] if _last_command_failed() == None else [
                    f"{_last_command_failed()}",
                    "#ffffff",
                    "#550000"
                ],
    "os": lambda: [
                    f' { " " if platform.system() == "Linux" else "󰨡 " } {platform.system()} ',
                    "#ffffff",
                    "#00462e"
                ],
    "branch": lambda: [
                    f" 󰊢  {_git_branch()} ",
                    "BLACK",
                    "#ffdb0d"
                ] if _git_hash() else None,
    "diff_count": lambda: [
                    f"   {_git_status()} ",
                    "#ffffff",
                    "#af0000"
                ] if _git_status() > 0 else None,
    "git_signing_key": lambda: [
                    f"   {_get_git_signing_key()} ",
                    "#000000",
                    "#ebebeb"
                ] if _git_hash() else None,
    "cpu_usage": lambda: [
                    f"   {__get_process_name_load_more_than_20pc()} ",
                    "#000000",
                    "#ffbb00"
                ] if __get_process_name_load_more_than_20pc() != None else None,
}

$PL_PROMPT='git_signing_key>cpu_usage\nos>cwd>branch>git_hash>git_summary>diff_count\nerror>user'
$RPL_PROMPT='!'
$PL_TOOLBAR='!'
$PL_RPROMPT='!'

xontrib load powerline2

# -------------------------------------------------------------------- powerline
