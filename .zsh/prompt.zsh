# prompt.zsh
# custom prompt

precmd() {
  if git rev-parse --git-dir &>/dev/null; then
    git diff --quiet && git diff --cached --quiet \
      && chevron_color=green || chevron_color=yellow
  else
    chevron_color=cyan
  fi

  case $PWD in
    $HOME) prompt_path="~" ;;
    $PROJECTS_DIR/*) prompt_path="${PWD/#$PROJECTS_DIR\//}" ;;
    $HOME/*) prompt_path="${PWD/#$HOME\//}" ;;
    *) prompt_path="$PWD" ;;
  esac

  [[ $PWD == $HOME ]] && print -n "\033]0;~\007" || print -n "\033]0;${PWD##*/}\007"
}

setopt PROMPT_SUBST
PROMPT='$prompt_path %(?.%F{$chevron_color}.%F{red})❯%f '
