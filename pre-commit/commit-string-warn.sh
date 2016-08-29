#!/usr/bin/env bash

#Some formatting variables
red=$(tput setaf 1)       
magenta=$(tput setaf 203) 
cyan=$(tput setaf 6)      
normal=$(tput sgr0)       

# General patch variables
gitroot=`git rev-parse --show-toplevel 2> /dev/null`
git_dir=`git rev-parse --git-dir 2> /dev/null`

warn_if_trying_to_commit() {
  # Enable getting interactive input from user
  exec < /dev/tty

  [[ -n "`git grep --cached \"$1\"`" ]] && local has_string=true || local has_string=false

  if [[ $has_string == true ]]; then
    local file=`git grep --cached --name-only "$1"`
    echo ""
    echo -e "${red}$file ${cyan}contains the string ${red}'$1'${normal}"
    read -p "Are you sure you want to commit it? ${red}(y/N)${normal} " answer
    if [[ "$answer" != "y" ]]; then
      exit 1;
    fi
  fi
}

# Warn when trying to commit code with unresolved merge conflicts
warn_if_trying_to_commit ">>>>>>>"

