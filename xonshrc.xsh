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
import threading
from blessed import Terminal
from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition
from prompt_toolkit.application import run_in_terminal

from git import Repo

__term = Terminal()
____username = getpass.getuser()

___THREAD_RESULT = None

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

os.environ["CASTELLO_SERVER"] = "192.168.0.52"
os.environ["DROPLET_IP"] = "143.198.182.128"
os.environ["AWS_SERVER"] = "ec2-3-133-114-116.us-east-2.compute.amazonaws.com"
os.environ["HOSTNAME"] = socket.gethostname()


# start the gpg agent
gpgconf --launch gpg-agent

# get the tty device and put in the GPG_TTY
$GPG_TTY = $(tty)

##
# Define the theme variant
##
# $THEME_VARIANT = "light"
# _THEME_VARIANT = "light"
$THEME_VARIANT = "dark"
_THEME_VARIANT = "dark"

_USER_HOME = os.path.expanduser("~")

##
# code insiders
##
# aliases['code'] = 'code-insiders'

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
aliases['C'] = 'clear'
aliases['ls'] = 'ls -lah --color=auto -v'
aliases['l'] = '/usr/bin/ls --color=auto -v'

# interop workaround for explorer
def __explorer(args):
    if "WSL_DISTRO_NAME" in os.environ:
        cmd = f'explorer.exe {" ".join(args)}'

    if platform.system() == "Darwin":
        cmd = f'open {" ".join(args)}'

    $(bash -c @(cmd))


aliases['explorer'] = __explorer

# connections

def __connect_to_server():
    if __xonsh__.env.get('WSL_DISTRO_NAME'):
        print("OPENING VS CODE")
        # set the dir to the windows path
        os.chdir("/mnt/c/Users/mpro3")
        cmd = f'cmd.exe /C code --remote ssh-remote+server'
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
    cmd = f'scp -r {args} root@{os.environ["DROPLET_IP"]}:{_USER_HOME}'
    $(bash -c @(cmd))

aliases['copy-to-droplet'] = __copy_to_droplet

def __connect_to_aws():
    ssh -i @(f"{_USER_HOME}/.ssh/telemetryKeys.pem") "ubuntu@$AWS_SERVER"

aliases['connect-to-aws'] = __connect_to_aws

def __copy_from_aws(args):
    args = f'{" ".join(args)}'
    cmd = f'scp -i "{_USER_HOME}/.ssh/telemetryKeys.pem" "ubuntu@$AWS_SERVER:{args}" .'
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


def __zed(args):
    # /home/microhobby/.local/bin/zed
    bash -c f"ZED_ALLOW_EMULATED_GPU=1 WAYLAND_DISPLAY='' zed {' '.join(args)}"


aliases['zed'] = __zed


def __torizon_dev_update(args):
    $__TCD_COMPOSE_FILE = f"{os.environ['HOME']}/.tcd/docker-compose.yml"
    $__TCD_BASH_COMPLETION_FILE = f"{os.environ['HOME']}/.tcd/torizon-dev-completion.bash"
    $__TCD_APOLLOX_REPO = "torizon/vscode-torizon-templates"
    $__TCD_BRANCH = "dev"
    $__TCD_BRANCH = "dev"
    $__TCD_UUID = $(id -u)
    $__TCD_DGID = $(getent group docker | cut -d: -f3)

    print("Pulling the torizon-dev image ...")
    # we pull everytime we source it to get updates
    docker \
        compose \
        -f $__TCD_COMPOSE_FILE \
        pull torizon-dev


aliases['torizon-dev-update'] = __torizon_dev_update


def __torizon_dev(args):
    # the torizon-dev-completion.bash was copied to
    # /usr/share/bash-completion/completions/torizon-dev
    # so we can use the bash completion
    $__TCD_COMPOSE_FILE = f"{os.environ['HOME']}/.tcd/docker-compose.yml"
    $__TCD_BASH_COMPLETION_FILE = f"{os.environ['HOME']}/.tcd/torizon-dev-completion.bash"
    $__TCD_APOLLOX_REPO = "torizon/vscode-torizon-templates"
    $__TCD_APOLLOX_BRANCH = "dev"
    $__TCD_BRANCH = "dev"
    $__TCD_UUID = $(id -u)
    $__TCD_DGID = $(getent group docker | cut -d: -f3)

    myhash = $(echo -n @(os.getcwd()) | openssl dgst -sha256 | sed 's/^.* //').strip()
    $SHA_DIR = myhash
    container_id = $(docker ps -aq -f name=@(f"torizon-dev-{myhash}"))

    if container_id != "":
        docker start @(f'torizon-dev-{myhash}') > /dev/null
    else:
        _workspace = os.path.basename(os.getcwd())
        print(f"Configuring environment for the [{_workspace}] workspace ...")
        print("Please wait ...")

        docker compose \
            -f $__TCD_COMPOSE_FILE \
            run \
            --entrypoint /bin/bash \
            --name @(f"torizon-dev-{myhash}") \
            --user root \
            -d torizon-dev > /dev/null

        docker exec -it --user root @(f"torizon-dev-{myhash}") usermod -u $__TCD_UUID torizon
        docker exec -it --user root @(f"torizon-dev-{myhash}") groupadd -g $__TCD_DGID docker
        docker exec -it --user root @(f"torizon-dev-{myhash}") usermod -aG $__TCD_DGID torizon
        docker exec -it --user root @(f"torizon-dev-{myhash}") chown -R torizon:torizon /home/torizon

    docker exec -it --user torizon @(f"torizon-dev-{myhash}") zygote @(args)


aliases['torizon-dev'] = __torizon_dev


def __check_copilot_install(args):
    ret = $(which gh)
    if not ret:
        print(f"{ERROR_EMOJI[0]} GitHub CLI not found, please install it: https://docs.github.com/en/copilot/github-copilot-in-the-cli/using-github-copilot-in-the-cli#prerequisites")
        return 69

    ret = $(gh extension list)
    if "copilot" not in ret:
        print(f"{ERROR_EMOJI[0]} GitHub Copilot not found, please install it: https://docs.github.com/en/copilot/github-copilot-in-the-cli/using-github-copilot-in-the-cli#prerequisites")
        return 69

@events.on_ptk_create
def custom_keybindings(bindings, **kw):

    @bindings.add(Keys.ControlE)
    def __explain_copilot(event):
        _old_y, _old_x = __term.get_location()

        def ___explain_copilot_thread():
            _buffer = event.current_buffer.text

            if _buffer == "":
                return

            def ____explain_robot():
                global ___THREAD_RESULT
                ___THREAD_RESULT = $($HOME/projects/X/xonsh-profile/scripts/ghcopilotE.sh @(_buffer))

            _t_robot = threading.Thread(target=____explain_robot)
            _t_robot.start()
            while _t_robot.is_alive():
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                # clear theline
                print(__term.clear_eol, end="", flush=True)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print("🤖 : .", end="", flush=True)
                time.sleep(0.1)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print(__term.clear_eol, end="", flush=True)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print("🤖 : ..", end="", flush=True)
                time.sleep(0.1)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print(__term.clear_eol, end="", flush=True)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print("🤖 : ...", end="", flush=True)
                time.sleep(0.1)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print(__term.clear_eol, end="", flush=True)
                print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                print("🤖 : ..", end="", flush=True)
                time.sleep(0.1)

            print(__term.move_xy(_old_x, _old_y), end="", flush=True)
            print(__term.clear_eol, end="", flush=True)
            print(___THREAD_RESULT)

        run_in_terminal(___explain_copilot_thread, True)


    # @bindings.add(Keys.ControlX)
    # def __execute_copilot(event):

    #     def ___execute_copilot_thread():
    #         event.current_buffer.insert_text(___THREAD_RESULT)
    #         # __xonsh__.execer.exec(___THREAD_RESULT)

    #     run_in_terminal(___execute_copilot_thread, True)


    @bindings.add(Keys.F10)
    def __copilot(event):
        _old_y, _old_x = __term.get_location()

        # we need to out of the prompter loop
        # so we can use the terminal
        def ___copilot_thread():
            # move the cursor to the bottom of the terminal
            print(__term.move_xy(0, __term.height - 2), end="", flush=True)
            print("🤖 : ", end="", flush=True)
            _input = input().strip()

            # make an animation
            def ____ask_robot():
                global ___THREAD_RESULT
                ___THREAD_RESULT = $($HOME/projects/X/xonsh-profile/scripts/ghcopilot.sh @(_input)).strip()

            if _input != "":
                _t_robot = threading.Thread(target=____ask_robot)
                _t_robot.start()

                while _t_robot.is_alive():
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    # clear theline
                    print(__term.clear_eol, end="", flush=True)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print("🤖 : .", end="", flush=True)
                    time.sleep(0.1)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print(__term.clear_eol, end="", flush=True)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print("🤖 : ..", end="", flush=True)
                    time.sleep(0.1)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print(__term.clear_eol, end="", flush=True)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print("🤖 : ...", end="", flush=True)
                    time.sleep(0.1)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print(__term.clear_eol, end="", flush=True)
                    print(__term.move_xy(0, __term.height - 2), end="", flush=True)
                    print("🤖 : ..", end="", flush=True)
                    time.sleep(0.1)

                # show to user
                print(__term.move_xy(_old_x, _old_y), end="", flush=True)
                event.current_buffer.insert_text(___THREAD_RESULT)
            else:
                # only go back the origin
                print(__term.move_xy(_old_x, _old_y), end="", flush=True)

        run_in_terminal(___copilot_thread, True)


def __vscode_git_fixups(args):
    # fix the vscode max file watchers
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p


aliases['vscode-git-fixups'] = __vscode_git_fixups


# -------------------------------------------------------------------- functions

# -------------------------------------------------------------------- path

$_ORIGINAL_PATH = $PATH[:]
[$PATH.remove(path) for path in $PATH.paths if path.startswith("/mnt/c/")]

# WARN: this only make sense for WSL
# vs code
if "WSL_DISTRO_NAME" in os.environ:
    ____code = "/mnt/c/Users/mpro3/AppData/Local/Programs/Microsoft VS Code/bin/code"
    ____code_dir = $(dirname @(____code))
    $PATH.insert(0, ____code_dir)

# explorer
if "WSL_DISTRO_NAME" in os.environ:
    ____programto = "/mnt/c/Windows/explorer.exe"
    ____programto_dir = $(dirname @(____programto))
    $PATH.insert(0, ____programto_dir)

# cmd.exe
if "WSL_DISTRO_NAME" in os.environ:
    if not os.path.exists("/usr/local/bin/cmd.exe"):
        print("Creating symlink for cmd.exe")
        print("You need to run this as administrator")
        $(sudo ln -s /mnt/c/Windows/System32/cmd.exe /usr/local/bin/cmd.exe)

# ipconfig.exe
if "WSL_DISTRO_NAME" in os.environ:
    ____programto = "/mnt/c/Windows/System32/ipconfig.exe"
    ____programto_dir = $(dirname @(____programto))
    $PATH.insert(0, ____programto_dir)

# powershell.exe
if "WSL_DISTRO_NAME" in os.environ:
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
                    "#A875FF" if _THEME_VARIANT == "dark" else "#4F17B0",
                    "RESET"
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
                    f' { " " if platform.system() == "Linux" else " " if platform.system() == "Darwin" else "󰨡 " } {platform.system()} ',
                    "#000000" if _THEME_VARIANT == "light" else "#C9C9C9",
                    "RESET"
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

# dark theme
$XONSH_STYLE_OVERRIDES['bottom-toolbar'] = 'noreverse'
$XONSH_STYLE_OVERRIDES['completion-menu'] = 'bg:#3e3e3e #2FD800'
$XONSH_STYLE_OVERRIDES['completion-menu.completion.current'] = 'fg:#2FD800 bg:#0D0D0D reverse'
# light theme
# $XONSH_STYLE_OVERRIDES['completion-menu'] = 'bg:#2a2a2a #a76cc9'


$PL_PROMPT='git_signing_key>cpu_usage\nos>cwd>branch>git_hash>git_summary>diff_count\nerror>user'
$RPL_PROMPT='!'
$PL_TOOLBAR='!'
$PL_RPROMPT='!'

xontrib load powerline2

# -------------------------------------------------------------------- powerline
$PATH.insert(0, f"/home/{os.environ['HOME']}/.local/bin")
