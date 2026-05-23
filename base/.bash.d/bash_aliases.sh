# Colors
alias ls='ls --hyperlink --color=auto'
alias ll='ls -l'
alias lla='ls -la'
alias la='ls -a'
eval $(dircolors -p | perl -pe 's/^((CAP|S[ET]|O[TR]|M|E)\w+).*/$1 00/' | dircolors -)
alias diff='diff --color=auto'
alias grep='grep --color=auto'
#export GREP_COLOR="1;32"
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

alias vi='nvim'
alias vim='nvim'
# alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias emacs='emacs-launcher'

# Use pnpm with security by default
alias npm='pnpm'
alias yarn='pnpm'

# Hub alias
eval "$(hub alias -s)"

## fzf
alias preview="fzf --preview 'bat --color \"always\" {}'"
# alias top="htop"
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias help="tldr"

# visudo
alias visudo="sudo -E /usr/bin/visudo"

# comcast-docker modification
alias comcast="docker run --rm --pid=host --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerinpractice/comcast"

# ssh alias
alias ssh='TERM=xterm-256color ssh'
#alias systemctl='sudo systemctl'

# Update local pip, https://dougie.io/answers/pip-update-all-packages/
alias pip-upgrade="pip freeze --user | cut -d'=' -f1 | xargs -n1 pip install -U"

# JVM Switcher
alias resetjdkpath='PATH=`echo $PATH | sed -Ee 's/[/]usr[/]lib[/]jvm[^:]+//g' | sed -Ee 's/:+/:/g'`'

alias java7oracleenv='
    resetjdkpath
    JAVA_HOME=/usr/lib/jvm/java-7-jdk
    J2SDKDIR=${JAVA_HOME}
    J2REDIR=${JAVA_HOME}/jre
    PATH=${JAVA_HOME}/bin:${JAVA_HOME}/db/bin:${JAVA_HOME}/jre/bin:$PATH
    java -version
'

alias java8env='
    resetjdkpath
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk
    J2SDKDIR=${JAVA_HOME}
    J2REDIR=${JAVA_HOME}/jre
    PATH=${JAVA_HOME}/bin:${JAVA_HOME}/db/bin:${JAVA_HOME}/jre/bin:$PATH
    java -version
'

alias java11env='
    resetjdkpath
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk
    J2SDKDIR=${JAVA_HOME}
    J2REDIR=${JAVA_HOME}/jre
    PATH=${JAVA_HOME}/bin:${JAVA_HOME}/db/bin:${JAVA_HOME}/jre/bin:$PATH
    java -version
'

# Mongo 3.6 utils alias with docker
# alias mongo='docker run -ti --rm=true -v `pwd`:/tmp -w /tmp -u 1000:1000 mongo:3.6-xenial mongo'
# alias mongoexport='docker run -ti --rm=true -v `pwd`:/tmp -w /tmp -u 1000:1000 mongo:3.6-xenial mongoexport'
# alias mongoimport='docker run -ti --rm=true -v `pwd`:/tmp -w /tmp -u 1000:1000 mongo:3.6-xenial mongoimport'
# alias mongodump='docker run -ti --rm=true -v `pwd`:/tmp -w /tmp -u 1000:1000 mongo:3.6-xenial mongodump'
# alias mongorestore='docker run -ti --rm=true -v `pwd`:/tmp -w /tmp -u 1000:1000 mongo:3.6-xenial mongorestore'

# Egrep alias
alias egrep='grep -E'
