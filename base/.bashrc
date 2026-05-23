#
# ~/.bashrc
#

# export BASH_IT_THEME='metal'
# export BASH_IT_THEME='powerline'
# export THEME_SHOW_PYTHON=true
# export POWERLINE_LEFT_PROMPT="scm python_venv node terraform ruby cwd"
# export POWERLINE_RIGHT_PROMPT="battery aws_profile clock user_info"
# # Activate bash-it
# export BASH_IT="$HOME/.bash_it"
# [[ -s "${BASH_IT}/bash_it.sh" ]] && source "${BASH_IT}/bash_it.sh"

# Activate bash_preexec
[[ -f ~/.bash_preexec.sh ]] && source ~/.bash_preexec.sh

# Activate oh-my-bash
# export OSH="$HOME/.oh-my-bash"
# [[ -s "$OSH/oh-my-bash.sh" ]] && source "$HOME/.oh_my_bash_env"

# eval $(keychain --eval --quiet id_rsa 37409E79 --gpg2 --noask)

## GPG Configuration: https://gist.github.com/kevinoid/189a0168ef4ceae76ed669cd696eaa37
if [ -t 0 ]; then
	# Set GPG_TTY so gpg-agent knows where to prompt.  See gpg-agent(1)
	export GPG_TTY="$(tty)"
	# Set PINENTRY_USER_DATA so pinentry-auto knows to present a text UI.
	export PINENTRY_USER_DATA=USE_TTY=1
fi

# Set history file per host
# https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
export HISTFILE=/home/$USER/.bash_history
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
  . /usr/share/doc/pkgfile/command-not-found.bash
fi

if [ -f /usr/share/git/completion/git-prompt.sh ]; then
  source /usr/share/git/completion/git-prompt.sh
fi

if [ -f /usr/share/doc/task/scripts/bash/task.sh ]; then
  source /usr/share/doc/task/scripts/bash/task.sh
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

if [ -d "$HOME/.bash.d" ]; then
  for f in "$HOME/.bash.d"/*.{bash,sh}; do
    [ -f "$f" ] && . "$f"
  done
fi

if [ -d "$HOME/.bash_completions.d" ]; then
  for f in "$HOME/.bash_completions.d"/*.{bash,sh}; do
    [ -f "$f" ] && source "$f"
  done
fi

#PS1='[\u@\h \W]\$ '
if [[ -n "$SSH_TTY" ]]; then
  export PS1='\[\e[1;31m\][SSH] \[\e[1;31m\]\u\[\e[0m\]@\[\e[1;31m\]\h \[\e[1;32m\]\w\[\e[0m\] \$ '
else
  export PS1='\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;34m\]\h \[\e[1;33m\]\w\[\e[0m\]$(__git_ps1 " (\e[32m%s\e[m)") \$ '
fi

# Environment
export XDG_CONFIG_HOME=$HOME/.config
export VISUAL="kate"
export EDITOR="nvim"

# PATH
[[ -d "$HOME/.local/bin" ]] && path_append "$HOME/.local/bin"
[[ -d "$HOME/bin" ]] && path_append "$HOME/bin"
[[ -d "$HOME/bin/sh" ]] && path_append "$HOME/bin/sh"
[[ -d "$HOME/.cargo/bin" ]] && path_append "$HOME/.cargo/bin"

# Go configuration
export GOPATH=$HOME/.go
[[ -d "$GOPATH" ]] && path_append "$GOPATH/bin"

# Add TeX Live installation to PATH (According to ChatGPT is better comment these variables)
path_prepend "/usr/local/texlive/2026/bin/x86_64-linux"
# export TEXDIR="/usr/local/texlive/2026"
# export TEXMFDIST="/usr/local/texlive/2026/texmf-dist"
# export TEXMFMAIN="/usr/local/texlive/2026/texmf-dist"
# export TEXMFLOCAL="/usr/local/texlive/texmf-local"
# export TEXMFSYSCONFIG="/usr/local/texlive/2026/texmf-config"
# export TEXMFSYSVAR="/usr/local/texlive/2026/texmf-var"
# export TEXMFVAR="$HOME/.texlive2026/texmf-var"
# export TEXMFCONFIG="$HOME/.texlive2026/texmf-config"
# export TEXMFHOME="$HOME/texmf"

export MANPATH="/usr/local/texlive/2026/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2026/texmf-dist/doc/info:$INFOPATH"

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
export _JAVA_AWT_WM_NONREPARENTING=1

_SILENT_JAVA_OPTIONS="$_JAVA_OPTIONS"
unset _JAVA_OPTIONS
alias java='java "$_SILENT_JAVA_OPTIONS"'
export GRAALVM_HOME=/usr/lib/jvm/java-8-graalvm

# export JGITFLOW_MVN_ARGUMENTS="-Dmaven.test.skip=true -Denv=aws"
export JGITFLOW_MVN_ARGUMENTS=""

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export GNU_ARM=/opt/gcc-arm/gcc-arm-none-eabi-8-2018-q4-major
[[ -d "$GNU_ARM/bin" ]] && path_append "$GNU_ARM/bin"

export GALLEON_PATH=/opt/javatools/galleon/galleon-4.2.8.Final
if [ -d "$GALLEON_PATH/bin" ]; then
  # export PATH="$PATH:$GALLEON_PATH/bin"
  path_append "$GALLEON_PATH/bin"
fi

export S2I_PATH=/opt/s2i
if [ -d "$S2I_PATH/bin" ]; then
  # export PATH="$PATH:$S2I_PATH/bin"
  path_append "$S2I_PATH/bin"
fi
#export FITS_LIBERATOR=/opt/fits-liberator

# Hazelcast jet
export HAZELCAST_JET_HOME=/opt/javatools/hazelcast/hazelcast-jet-4.5.1
if [ -d "$HAZELCAST_JET_HOME/bin" ]; then
  # export PATH="$PATH:$HAZELCAST_JET_HOME/bin"
  path_append "$HAZELCAST_JET_HOME/bin"
fi
export MAVEN_CHECK_HOME=/opt/maven-check/maven-check-1.4.0
if [ -d "$MAVEN_CHECK_HOME/bin" ]; then
  # export PATH="$PATH:$MAVEN_CHECK_HOME/bin"
  path_append "$MAVEN_CHECK_HOME/bin"
fi

# Local node_modules/bin
# export LOCAL_NODE_MODULES_BIN=./node_modules/.bin

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# RVM bash completion
#[[ -r "$HOME/.rvm/scripts/completion" ]] && source "$HOME/.rvm/scripts/completion"


# Using nvm for set npm environments
[[ -s "/usr/share/nvm/init-nvm.sh" ]] && source /usr/share/nvm/init-nvm.sh

# cowsay $(fortune -o)
export ANSIBLE_NOCOWS=1

# Enable direnv
[ -x "$(which direnv)" ] && eval "$(direnv hook bash)"

# Enable pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT" ]] || mkdir -p "$PYENV_ROOT"
## Check if pyenv is installed, is so init pyenv, otherwise print a warning
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
fi
if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
  eval "$(pyenv virtualenv-init -)"
fi

# Set default aws
export AWS_PROFILE=default

# Terraform data dir
export TF_DATA_DIR=$HOME/.terraform_data

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        # export PATH="/opt/miniconda3/bin:$PATH"
        path_prepend "/opt/miniconda3/bin"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# Jupyter lab path
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab

# DVT license
export DVT_LICENSE_FILE=$HOME/.dvt/dvt-20250625.license

# Kiota - OpenApi generator
export KIOTA_HOME=/opt/kiota
if [ -d "$KIOTA_HOME/bin" ]; then
  # export PATH="$PATH:$KIOTA_HOME/bin"
  path_append "$KIOTA_HOME/bin"
fi

# Add asdf
export ASDF_DATA_DIR=$HOME/.asdf
if [ -d "$ASDF_DATA_DIR" ]; then
  # export PATH="$ASDF_DATA_DIR/shims:$PATH"
  path_prepend "$ASDF_DATA_DIR/shims"
  . <(asdf completion bash)
fi

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r "$HOME/.opam/opam-init/init.sh" && . "$HOME/.opam/opam-init/init.sh" > /dev/null 2> /dev/null || true
# END opam configuration

# Add dotnet tools
if [ -d "$HOME/.dotnet/tools" ] ; then
    # export PATH="$HOME/.dotnet/tools:$PATH"
    path_prepend "$HOME/.dotnet/tools"
fi

# Adding starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
