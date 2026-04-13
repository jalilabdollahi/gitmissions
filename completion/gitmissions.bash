_gitmissions_completions()
{
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "check watch hint solution guide debrief reset skip status help quit" -- "$cur") )
}
complete -F _gitmissions_completions gitmissions
