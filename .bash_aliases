# Message & notification

show_message() {
  local msg=""
  local ide=$(echo $TERMINAL_EMULATOR)
  local code=""

  if [[ ${BASH_VERSION%%[^0-9]*} > 3 ]]; then
    code="\e"
  else
    code="\x1B"
  fi

  if [ -z $ide ]; then
    msg+="$code[0;33m"
  else
    msg+="$code[37m"
  fi

  local now=$(date +"%T.%N")
  local del_color="$code[0m"

  msg+="$now${del_color} "

  if [ "$#" == 1 ]; then
    msg+="> $1"
  else
    local text="$2"
    local reg='^\w+ing(|\s[^\.]+)$'

    if [ -z $ide ]; then
      msg+="$code[96m"
    else
      msg+="$code[34m"
    fi

    msg+="< $1 >${del_color} ${text}"

    if [[ $text =~ $reg ]]; then
      msg+="..."
    fi
  fi

  echo -e $msg
}

execute_notification() {
  if [ $(uname) == 'Darwin' ]; then
    osascript -e "display notification \"$2\" with title \"$1\""
  else
    notify-send "$1" "$2"
  fi
}

# Parse projects info file.

parse_yaml() {
  local file_name="$HOME"'/projects.yml'
  local prefix='project_'
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $file_name |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}

# Get project settings prefix.

get_project() {
  eval $(parse_yaml)
  local conf=$(( set -o posix ; set ) | cat | grep '^project\_[a-z0-9]*\_local\_directory\='$(pwd)'$')

  if [ -z $conf ]; then
    echo ''
  else
    echo 'project_'$(echo $conf | sed 's/^project\_\([^\_]*\).*$/\1/')'_'
  fi
}

# Getting variable value.

get() {
  eval $(parse_yaml)
  echo ${!1}
}

# SSH

execute_remote() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local environment="$1"
    local ssh="${project}${environment}_ssh_"
    local host=$(get "${ssh}host")

    if ! [ -z $host ]; then
      local user=$(get "${ssh}user")

      if ! [ -z $user ]; then
        local title=$(get "${project}info_title")
        show_message "SSH" "Connecting to \"${environment}\" host of \"${title}\" project"

        local port=$(get "${ssh}port")

        if [ -z $port ]; then
          port=22
        fi

        local directory=$(get "${ssh}directory")

        if ! [ -z $directory ]; then
          ssh -p ${port} ${user}@${host} -t "cd ${directory} ; bash"
        else
          ssh -p ${port} ${user}@${host}
        fi
      else
        show_message "SSH" "User not defined!"
      fi
    else
      show_message "SSH" "Host not defined!"
    fi
  else
    show_message "Undefined project!"
  fi
}

alias erd="execute_remote dev"
alias erl="execute_remote live"

execute_remote_transfer() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local environment="$1"
    local ssh="${project}${environment}_ssh_"
    local host=$(get "${ssh}host")

    if ! [ -z $host ]; then
      local user=$(get "${ssh}user")

      if ! [ -z $user ]; then
        local title=$(get "${project}info_title")
        show_message "SSH" "Downloading file(s) from \"${environment}\" host of \"${title}\" project"

        local port=$(get "${ssh}port")

        if [ -z $port ]; then
          port=22
        fi

        scp -P ${port} ${user}@${host}:$2 .
      else
        show_message "SSH" "User not defined!"
      fi
    else
      show_message "SSH" "Host not defined!"
    fi
  else
    show_message "Undefined project!"
  fi
}

alias erdt="execute_remote_transfer dev $1"
alias erlt="execute_remote_transfer live $1"

# Composer

execute_composer_install() {
  show_message "Composer" "Installing"
  composer install $@
}

alias eci=execute_composer_install

execute_composer_update() {
  show_message "Composer" "Updating"
  composer update $@
}

alias ecu=execute_composer_update

execute_composer_update_debug() {
  show_message "Composer" "Updating in debug mode..."
  composer update -vvv $@
}

alias ecud=execute_composer_update_debug

execute_composer_production() {
  show_message "Composer" "Updating production"
  composer update --no-dev $@
}

alias ecp=execute_composer_production

execute_composer_require() {
  show_message "Composer" "Adding package"
  composer require $@
}

alias ecr=execute_composer_require

# GIT

alias gs='git status '
alias gb='git branch '
alias gba='git branch -a '
alias gc='git commit -m '
alias gd='git diff '

execute_git_add() {
  if [ "$#" == 0 ]; then
    show_message "Git" "Adding all changes"
    git add .
  else
    show_message "Git" "Adding some changes"
    git add $@
  fi
}

alias ega=execute_git_add

execute_git_branch() {
  if [ "$#" == 0 ]; then
    show_message "Git" "Switching to the previous branch"
    git switch -
  else
    show_message "Git" "Switching to \"$1\" branch"
    git switch $1
  fi
}

alias egbs=execute_git_branch

execute_git_branch_environment() {
  local project=$(get_project)
  local branch=''

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}$1_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  if [ -z $branch ]; then
    for ((i = 2; i <= $#; i++ )); do
      local exists=$(git branch --list ${!i})

      if ! [ -z "${exists}" ]; then
        branch=${!i}
        break
      fi
    done
  fi

  execute_git_branch $branch
}

alias egbd='execute_git_branch_environment dev dev'
alias egbm='show_message Deprecated "Use egm instead"'

execute_git_changes() {
  if [ "$#" == 0 ]; then
    show_message "Git" "Canceling all changes"
    git checkout .
  else
    show_message "Git" "Canceling some changes"
    git checkout $@
  fi
}

alias egch=execute_git_changes

execute_git_delete() {
  show_message "Git" "Deleting \"$1\" branch"
  git branch -D $1
}

alias egd=execute_git_delete

alias gk='gitk --all&'
alias gx='gitx --all'
alias gf='git fetch '
alias gl='git log '

git_init() {
  git init
  git config core.fileMode false
}

alias egi=git_init

execute_git_patch() {
  show_message "Git" "Applying a patch"

  if [ -z $1 ]; then
    echo "The command should have at least one parameter!" >> /dev/stderr
  else
    git apply $@
  fi
}

alias egp=execute_git_patch

alias egr='git rm '
alias egrs='git remote -v'
alias egra='git remote add '
alias egrao='git remote add origin '

execute_git_remote_change() {
  show_message "Git" "Change origin URL to remote repository"
  git remote set-url origin $1
}

alias egrc=execute_git_remote_change

execute_git_revert() {
  show_message "Git" "Reverting some existing commit(s)"
  git revert $@
}

alias egrv=execute_git_revert

execute_git_clone() {
  local remote=""
  local directory=""
  local branch=""
  local user=""
  local mail=""
  local email=""
  local project=false

  if [ -d .git ]; then
    show_message "Git" "Re-cloning"

    remote=$(git remote get-url origin)
    directory=${PWD##*/}
    branch=$(git rev-parse --abbrev-ref HEAD)
    user=$(git config user.name)
    mail=$(git config user.mail)
    email=$(git config user.email)

    if [ -d .idea ]; then
      mv .idea ..
      project=true
    fi

    cd ..
    sudo rm -rf $directory
  else
    show_message "Git" "Cloning"

    remote=$1
    directory=$2

    local projects_user=$(get project_git_user)

    if ! [ -z "${projects_user}" ]; then
      user=$projects_user
    fi

    local projects_mail=$(get project_git_mail)

    if ! [ -z $projects_mail ]; then
      mail=$projects_mail
      email=$projects_mail
    fi
  fi

  git clone $remote $directory
  cd $directory
  git config core.fileMode false

  if ! [ -z $branch ]; then
    execute_git_branch $branch
    execute_git_pull $branch
  fi

  if ! [ -z "${user}" ]; then
    git config user.name "${user}"
  fi

  if ! [ -z $mail ]; then
    git config user.mail $mail
  fi

  if ! [ -z $email ]; then
    git config user.email $email
  fi

  if $project ; then
    mv ../.idea .
  fi
}

alias egc=execute_git_clone

alias egb='git checkout -b '
alias egcp='git cherry-pick '
alias egcpc='git cherry-pick --continue '
alias egfm='git config core.fileMode '
alias egfmd='git config core.fileMode false '

execute_git_fetch() {
  show_message "Git" "Fetching"
  git fetch --prune
}

alias egf=execute_git_fetch

alias egm='execute_git_branch_environment live master main'

execute_git_push() {
  show_message "Git" "Pushing to \"$1\" branch"
  git push origin $1
}

alias egh=execute_git_push

execute_git_push_environment() {
  local project=$(get_project)
  local branch="$1"

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}$2_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  execute_git_push $branch
}

alias eghd='execute_git_push_environment develop dev'
alias eghm='execute_git_push_environment master live'

execute_git_pull() {
  show_message "Git" "Pulling from \"$1\" branch"
  git pull origin $1
}

alias egl=execute_git_pull

execute_git_pull_environment() {
  local project=$(get_project)
  local branch=''

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}$1_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  if [ -z $branch ]; then
    for ((i = 2; i <= $#; i++ )); do
      local exists=$(git branch --list ${!i})

      if ! [ -z "${exists}" ]; then
        branch=${!i}
        break
      fi
    done
  fi

  execute_git_pull $branch
}

alias egld='execute_git_pull_environment dev dev'
alias eglm='execute_git_pull_environment live master main'

git_stash() {
  show_message "Git" "Stashing the changes in a dirty working directory away"
  git stash $@
}

alias egs=git_stash

git_stash_apply() {
  show_message "Git" "Applying a single stashed state on top of the current working tree state"
  git stash apply $@
}

alias egsa=git_stash_apply

git_submodule_add_core() {
  show_message "Git" "Adding Drupal core as a submodule"
  git submodule add --branch 7.x https://git.drupalcode.org/project/drupal.git htdocs
}

alias egsm=git_submodule_add_core

git_submodule_add_module() {
  show_message "Git" "Adding a Drupal module as a submodule"
  git submodule add --branch 7.x-$2.x https://git.drupalcode.org/project/$1.git sites/all/modules/contrib/$1
}

alias egsma=git_submodule_add_module

git_submodule_update() {
  show_message "Git" "Updating submodules"
  git submodule update --init $@
}

alias egsmu=git_submodule_update

execute_git_user() {
  local name=$(git config user.name)
  local email=$(git config user.email)
  show_message "Git" "Owner of future commits will be ${name} <${email}>"
}

alias egu=execute_git_user

execute_git_user_fix() {
  local user=$(get project_git_user)

  if ! [ -z "${user}" ]; then
    git config user.name "${user}"
  fi

  local mail=$(get project_git_mail)

  if ! [ -z $mail ]; then
    git config user.mail $mail
    git config user.email $mail
  fi

  execute_git_user
}

alias eguf=execute_git_user_fix

# Docker

alias edrs='sudo service docker start '
alias edrp='sudo service docker stop '

docker_clear() {
  show_message "Docker" "Stoping containers"
  docker stop $(docker ps -q)
  show_message "Docker" "Removing containers"
  docker rm -f $(docker ps -a -q)
  show_message "Docker" "Removing images"
  docker rmi -f $(docker images -a -q)
  show_message "Docker" "Removing volumes"
  docker volume rm $(docker volume ls -q)
  show_message "Docker" "Removing networks"
  docker network rm $(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')
  show_message "Docker" "Results"
  docker ps -a
  docker images -a
  docker volume ls
}

alias edrc=docker_clear

execute_docker_list() {
  show_message "Docker" "Getting list of running containers"
  docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}"
}

alias edrl=execute_docker_list

execute_docker_execute() {
  local arguments=$@

  if [ "$#" == 1 ]; then
    show_message "Docker" "Connecting to a container"
    arguments+=" bash"
  elif [[ ${#FUNCNAME[@]} == 1 ]]; then
    show_message "Docker" "Executing any command"
  fi

  docker exec -it ${arguments}
}

alias edre=execute_docker_execute

alias edra='sudo chmod +x $(find . -name "*.sh") '

execute_docker_compose() {
  if [ -z $(which docker-compose)]; then
    docker compose $@
  else
    docker-compose $@
  fi
}

execute_docker_up() {
  show_message "Docker" "Upping"
  execute_docker_compose up -d $@
}

alias edru=execute_docker_up

execute_docker_down() {
  show_message "Docker" "Downing"
  execute_docker_compose down $@
}

alias edrd=execute_docker_down

execute_docker() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local container=$(get "${project}docker")

    if ! [ -z $container ]; then
      edre $container $@
      return
    fi
  fi

  $@
}

execute_docker_database_container() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local container=$(get "${project}docker_db")

    if ! [ -z $container ]; then
      echo $container
      return
    fi
  fi
}

# MySQL

alias ems='sudo service mysql start '
alias emp='sudo service mysql stop '
alias em='mysql -u root -proot '

mysql_import() {
  show_message "MySQL" "Importing database"
  pv $2 | mysql -u root -proot $1
}

alias emi=mysql_import

mysql_export() {
  mysqldump -u root -proot $1 > $2.sql
  show_message "MySQL" "Created dump for database called $1 in file $2.sql"
}

alias eme=mysql_export

execute_mysql_create_db() {
  show_message "MySQL" "Creating \"$1\" database"

  local container=$(execute_docker_database_container)
  local database=$1

  if [ -z $container ]; then
    mysql -u root -proot -e "create database ${database}"
  else
    docker exec -it $container mysql -u root -proot -e "create database ${database}"
  fi

  show_message "MySQL" "Created database called \"$1\"."
}

alias emc=execute_mysql_create_db

execute_mysql_drop_db() {
  show_message "MySQL" "Deleting \"$1\" database"

  local container=$(execute_docker_database_container)
  local database=$1

  if [ -z $container ]; then
    mysql -u root -proot -e "drop database ${database}"
  else
    docker exec -it $container mysql -u root -proot -e "drop database ${database}"
  fi
}

alias emd=execute_mysql_drop_db

execute_mysql_reload() {
  local database=$1
  local dump="$2"

  if [ -z "$dump" ]; then
    local project_name=$(get_project)
    local project_database=$(get "${project_name}local_database")

    if [ -z $database ]; then
      database=$project_database
    else
      if [ -z $project_database ]; then
        return
      else
        dump=$database
        database=$project_database
      fi
    fi
  fi

  emd $database
  emc $database

  if [ $# == 0 ]; then
    return
  fi

  local container=$(execute_docker_database_container)

  show_message "MySQL" "Loading \"${database}\" database from \"${dump}\" file"

  if [ -z $container ]; then
    pv $dump | mysql -u root -proot $database
  else
    if [ -f "$dump" ]; then
      docker cp $dump "${container}:/"
    fi

    docker exec -it $container bash -c "mysql -u root -proot ${database} < ${dump}"
  fi

  show_message "MySQL" "Recreated \"${database}\" database and load data from \"${dump}\" dump file."
}

alias emr=execute_mysql_reload

mysql_create_user() {
  mysql -u root -proot -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "MySQL" "Created user \"$1\" for \"$1\" database."
}

alias emu=mysql_create_user

mysql_create_user_special() {
  mysql -u root -proot -e "CREATE USER '$2'@'localhost' IDENTIFIED BY '$3'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "MySQL" "Created user \"$2\" for \"$1\" database."
}

alias emus=mysql_create_user_special

# Drush

execute_drush() {
  local arguments=$@
  local project=$(get_project)

  if ! [ -z $project ]; then
    local uri=$(get "${project}drush_uri")

    if ! [ -z $uri ]; then
      arguments+=" --uri=${uri}"
    fi

    execute_docker drush "${arguments}"
  fi
}

execute_drush_execute() {
  show_message "Drush" "Executing any command"
  execute_drush $@
}

alias eds=execute_drush_execute

execute_drush_clear() {
  show_message "Drush" "Clearing all caches"

  local project=$(get_project)
  local docker=0

  if ! [ -z $project ]; then
    local container=$(get "${project}docker")

    if ! [ -z $container ]; then
      execute_drush cr
      docker=1
    fi
  fi

  if [ $docker == 0 ]; then
    if [ -e index.php ]; then
      if [ -e core ]; then
        drush cr
      else
        drush cc all
      fi
    else
      show_message "Site not found!"
    fi
  fi
}

alias edsc=execute_drush_clear

execute_drush_clear_database() {
  show_message "Drush" "Dropping all tables in a given database"

  if [ "$#" == 0 ]; then
    execute_drush sql-drop --yes
  else
    execute_drush sql-drop $@
  fi
}

alias edscd=execute_drush_clear_database

execute_drush_clear_log() {
  show_message "Drush" "Clearing a log"
  execute_drush wd-del all -y $@
}

alias edscl=execute_drush_clear_log

execute_drush_cron() {
  show_message "Drush" "Running cron"
  execute_drush cron
}

alias edsn=execute_drush_cron

execute_drush_clear_root() {
  show_message "Drush" "Clearing all caches by root"
  execute_docker sudo drush cc all
}

alias edscr=execute_drush_clear_root

execute_drush_dump() {
  show_message "Drush" "Creating dump of database"
  execute_drush sql-dump --result-file=$1.sql
}

alias edsd=execute_drush_dump

execute_drush_module_install() {
  show_message "Drush" "Installing module(s)"
  execute_drush -y en $@
}

alias ei=execute_drush_module_install
alias edsmi=execute_drush_module_install

execute_drush_module_uninstall() {
  show_message "Drush" "Uninstalling module(s)"
  execute_drush -y pmu $@
}

alias edsmu=execute_drush_module_uninstall

execute_drush_config_export() {
  show_message "Drush" "Exporting configuration"
  execute_drush -y cex
}

alias edsce=execute_drush_config_export

execute_drush_config_import() {
  show_message "Drush" "Importing configuration"
  execute_drush -y cim
}

alias edsci=execute_drush_config_import

execute_drush_user_login() {
  local host='127.0.0.1'
  local project=$(get_project)

  if ! [ -z $project ]; then
    local container=$(get "${project}docker")

    if ! [ -z $container ]; then
      local ports=$(docker ps --filter name=^/${container}$ --format "{{.Ports}}")
      ports="${ports/0.0.0.0:/}"
      ports="${ports/->80\/tcp/}"
      host+=":${ports}"
    fi
  fi

  local user=$1

  if [ -z $user ]; then
    user=1
  fi

  show_message "Drush" "Generating a one time login link for the user account with uid ${user}"

  local url=$(execute_drush uli --uid=${user})

  echo "${url/default/$host}"
}

alias edsl=execute_drush_user_login

execute_drush_user_login_uid_1_no_browser() {
  show_message "Drush" "Display a one time login link for the uid 1 user account without openning browser."
  execute_drush uli --uid=$1 --no-browser
}

alias edslfn=execute_drush_uli_uid_no_browser

execute_drush_queue() {
  show_message "Drush" "Getting queues"
  execute_drush queue-list $@
}

alias edsq=execute_drush_queue

execute_drush_status() {
  show_message "Drush" "Getting status"
  execute_drush status
}

alias edss=execute_drush_status

execute_drush_status_database() {
  show_message "Drush" "Getting database name"
  execute_drush status --fields=db-name
}

alias edssd=execute_drush_status_database

execute_drush_update_database() {
  show_message "Drush" "Updating database"
  execute_drush -y updb
}

alias edsu=execute_drush_update_database

execute_drush_feature() {
  show_message "Drush" "Updating feature"

  if [ -z $1 ]; then
    echo "The command should have one parameter!" >> /dev/stderr
  else
    execute_drush -y fr $1
  fi
}

alias edsf=execute_drush_feature

# Apache

execute_apache() {
  show_message "Apache" $1

  if [ $(uname) == 'Darwin' ]; then
    sudo apachectl $2
  else
    sudo service apache2 $2
  fi
}

alias eas='execute_apache Starting start '
alias ear='execute_apache Restarting restart '
alias eap='execute_apache Stopping stop '

alias eae='sudo a2ensite '
alias ead='sudo a2dissite '

# Tar

execute_tar_extract() {
  show_message "Tar" "Extracting"
  local file=$1

  if [[ $file =~ \.gz$ ]]; then
    tar zxfv ${file}
  else
    tar -xvf ${file}
  fi
}

alias ete=execute_tar_extract

# Drupal

execute_drupal_db() {
  show_message "Drupal" "Getting database name"
  cat sites/default/settings.php | grep "'database'"
}

alias edld=execute_drupal_db

execute_drupal_update() {
  show_message "Drupal" "Updating module or theme"

  if ! [ -z "$2" ]; then
    rm -rf $2

    if [ $(uname) == 'Darwin' ]; then
      curl $1$2$3 -o $2$3
    else
      wget $1$2$3
    fi

    tar zxfv $2$3
    rm $2$3
  else
    rm -rf $1
    mv $(find ~/Downloads -name "${1}*") .
    local file=$(ls ${1}*.tar*)
    ete $file
    rm $file
  fi
}

alias edlu=execute_drupal_update

# platform.sh

execute_platform() {
  show_message "platform.sh" "Creating dump of database"

  local file="${1}.sql"

  if [ -f $file ]; then
    rm $file
  fi

  file+=".gz"
  platform db:dump --gzip -f $file
  gunzip $file
}

alias epsh=execute_platform

# Projects data

execute_project_update_all() {
  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
  else
    local title=$(get "${project}info_title")
    show_message "${title}" "Updating database"
    local remote="${project}remote_"
    local host="${remote}host"
    local user="${remote}user"
    local password="${remote}password"
    local database="${remote}database"
    mysqldump -y -h $(get $host) -u $(get $user) -p$(get $password) $(get $database) > db.sql
    emr $(get "${project}local_database") db.sql
    rm db.sql
  fi
}

alias epua=execute_project_update_all

execute_project() {
  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
  else
    local title=$(get "${project}info_title")
    show_message "${title}" "Reinstalling site"

    local function="execute_${project%_*}"

    if [ -z "$(cat ~/.bash_aliases | grep $function)" ]; then
      epua
      edsc
    else
      eval $function
    fi

    execute_notification "${title}" "The project has been installed."
  fi
}

alias ep=execute_project

# Others

execute_system_deploy() {
  show_message "System" "Deploying"

  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
    return
  fi

  project+="local_deploy_"
  local steps=$(get "${project}amount")

  if [ -z $steps ]; then
    return
  fi

  local step=1

  while [ $step -le $steps ]; do
    echo $(get "${project}steps_${step}_type")
    ((step++))
  done
}

alias esd=execute_system_deploy

alias esf='cd /hdd/www/'

execute_system_permissions() {
  show_message "System" "Setting the webserver user as the owner of the Drupal default files directory"

  local name='www-data'

  if [ $(uname) == 'Darwin' ]; then
    name='_www'
  fi

  sudo chown -R $name:$name sites/default
}

alias esp=execute_system_permissions

execute_system_commands_edit() {
  show_message "System" "Editing commands file"
  nano ~/.bash_aliases
}

alias esc=execute_system_commands_edit

execute_system_commands_search() {
  local phrase=$1
  show_message "System" "Looking for \"$phrase\" in the commands file"
  cat ~/.bash_aliases | grep "$phrase"
}

alias escf=execute_system_commands_search

execute_system_hosts() {
  show_message "System" "Editing hosts file"

  local editor='grep'

  if [ $(uname) == 'Darwin' ]; then
    editor='nano'
  fi

  sudo $editor /etc/hosts
}

alias esh=execute_system_hosts

execute_system_environment() {
  STATUS=$(sudo service docker status)
  if [ "$STATUS" == "docker stop/waiting" ]; then
    show_message "Changing environment from local to Docker"
    eap
    emp
    edrs
  else
    show_message "Changing environment from Docker to local"
    edrp
    eas
    ems
  fi
}

alias ese=execute_system_environment

execute_system_space() {
  show_message "System" "Getting free space on the disks"
  df -h --output=source,target,avail | grep /dev/sd
}

alias ess=execute_system_space

alias q='exit'
