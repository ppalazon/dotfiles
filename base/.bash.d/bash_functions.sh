# Extract
shopt -s extglob

path_prepend() {
  [ -d "$1" ] || return

  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

path_append() {
  [ -d "$1" ] || return

  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$PATH:$1" ;;
  esac
}

extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

# cd and ls
cl() {
	local dir="$1"
	local dir="${dir:=$HOME}"
	if [[ -d "$dir" ]]; then
		cd "$dir" >/dev/null; ls
	else
		echo "bash: cl: $dir: Directory not found"
	fi
}

# Calculator
calc() {
    echo "scale=3;$@" | bc -l
}

# IP Info
ipif() { 
    if grep -P "(([1-9]\d{0,2})\.){3}(?2)" <<< "$1"; then
	curl ipinfo.io/"$1"
    else
	ipawk=($(host "$1" | awk '/address/ { print $NF }'))
	curl ipinfo.io/${ipawk[1]}
    fi
    echo
}

cheat(){ curl cheat.sh/"$1"; }

# Countdown and Stopwatch
function countdown(){
   date1=$((`date +%s` + $1)); 
   while [ "$date1" -ge `date +%s` ]; do 
     echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}
function stopwatch(){
  date1=`date +%s`; 
   while true; do 
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"; 
    sleep 0.1
   done
}

function gi() {
  curl -sL https://www.toptal.com/developers/gitignore/api/$@;
}

function dotfiles-update() {
  config pull && config commit -am 'Save dotfiles' && config push
}

# Docker image ip
function docker-ip(){
  docker inspect $1 | jq ".[0].NetworkSettings.Networks.bridge.IPAddress"
}

# jgitflow functions
function pre-jgitflow() {
:
}

function test-pre-jgitflow() {
  echo "Init pre-maven" && pre-jgitflow && echo "Finish pre-maven"
}

function hotfix-start() {
  pre-jgitflow && mvn jgitflow:hotfix-start ${JGITFLOW_MVN_ARGUMENTS}
}

function hotfix-finish() {
  pre-jgitflow && mvn jgitflow:hotfix-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags && mvn clean
}

function feature-start() {
  pre-jgitflow && mvn jgitflow:feature-start ${JGITFLOW_MVN_ARGUMENTS}
}

function feature-finish() {
  pre-jgitflow && mvn jgitflow:feature-finish ${JGITFLOW_MVN_ARGUMENTS} && mvn clean
  echo -e '\033[32m----------------------------------------------------------------\033[0m'
  echo -e '\033[32m===== REMEMBER TO CREATE A NEW RELEASE TO DEPLOY THIS FEATURE ====\033[0m'
  echo -e '\033[32m----------------------------------------------------------------\033[0m'
}

function release-start() {
  pre-jgitflow && mvn jgitflow:release-start ${JGITFLOW_MVN_ARGUMENTS}
}

function release-finish {
  pre-jgitflow && mvn jgitflow:release-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags && mvn clean
}
