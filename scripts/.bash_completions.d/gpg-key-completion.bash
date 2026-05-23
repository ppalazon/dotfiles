_get_gpg_keys() {
  local mode="$1"
  local gpg_cmd record_type

  case "$mode" in
    pub)
      gpg_cmd=(gpg --list-keys --with-colons)
      record_type="pub"
      ;;
    sec)
      gpg_cmd=(gpg --list-secret-keys --with-colons)
      record_type="sec"
      ;;
    *)
      return 1
      ;;
  esac

  "${gpg_cmd[@]}" 2>/dev/null | \
    awk -F: -v record_type="$record_type" '
      $1 == record_type {
        key = $5
        fpr = ""
        next
      }

      $1 == "fpr" && fpr == "" {
        fpr = $10
        next
      }

      $1 == "uid" && fpr != "" && !seen[fpr]++ {
        # FIELD1 = fingerprint (hidden/used)
        # FIELD2 = display (UID + short key)
        printf "%s\t%s (%s)\n", fpr, $10, key
      }
    '
}

_gpg_keys_completion() {
  local cur selected

  cur="${COMP_WORDS[COMP_CWORD]}"

  selected=$(_get_gpg_keys pub | \
    fzf --query="$cur" \
        --with-nth=2 \
        --delimiter=$'\t')

  if [[ -n "$selected" ]]; then
    # extract fingerprint (field 1)
    COMPREPLY=("${selected%%$'\t'*}")
  fi
}

_gpg_secret_keys_completion() {
  local cur selected

  cur="${COMP_WORDS[COMP_CWORD]}"

  selected=$(_get_gpg_keys sec | \
    fzf --query="$cur" \
        --with-nth=2 \
        --delimiter=$'\t')

  if [[ -n "$selected" ]]; then
    # extract fingerprint (field 1)
    COMPREPLY=("${selected%%$'\t'*}")
  fi
}

_gpg_key_and_directory_completion() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()

  case $COMP_CWORD in
    1)
      _gpg_secret_keys_completion
      ;;
    2)
      while IFS= read -r dir; do
        COMPREPLY+=("$dir")
      done < <(compgen -d -- "$cur")

      compopt -o filenames -o dirnames
      ;;
  esac
}

_gpg_key_and_file_completion() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()

  case $COMP_CWORD in
    1)
      _gpg_secret_keys_completion
      ;;
    2)
      mapfile -t COMPREPLY < <(compgen -f -- "$cur")
      compopt -o filenames
      ;;
  esac
}


# Using private keys
complete -F _gpg_secret_keys_completion gpg-key-backup
complete -F _gpg_secret_keys_completion gpg-key-backup-revoke-cert
complete -F _gpg_secret_keys_completion gpg-key-delete
complete -F _gpg_secret_keys_completion gpg-key-edit
complete -F _gpg_secret_keys_completion gpg-key-fingerprint
complete -F _gpg_secret_keys_completion gpg-key-master-status
complete -F _gpg_secret_keys_completion gpg-key-send
complete -F _gpg_secret_keys_completion gpg-key-ssh-copy-id
complete -F _gpg_secret_keys_completion gpg-key-ssh-export
complete -F _gpg_secret_keys_completion gpg-key-ssh-list

# Using master completion
complete -F _gpg_key_and_directory_completion gpg-key-master-off
complete -F _gpg_key_and_file_completion gpg-key-master-on
complete -F _gpg_key_and_file_completion gpg-key-revoke

# # Using public keys
complete -F _gpg_keys_completion gpg-key-info
complete -F _gpg_keys_completion gpg-key-share
complete -F _gpg_keys_completion gpg-key-wkd-export