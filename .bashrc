project=$(get_project)

if [ -z $project ]; then
  project="LOCAL: \[\033[1;33m\]\w"
else
  project=$(get "${project}info_title")
fi

PS1="\[\033[1;32m\]$project \[\033[10;31m\]> \[\033[0m\]\[\033[0m\]"

unset project

