precmd() {
  if git rev-parse --git-dir &>/dev/null; then
    git diff --quiet && git diff --cached --quiet \
      && branch_color=8 || branch_color=yellow
    git_branch=" %F{$branch_color}${$(git symbolic-ref --quiet --short HEAD):-detached}%f"
  else
    git_branch=""
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
PROMPT='$prompt_path$git_branch %(?.%F{green}.%F{red})❯%f '
