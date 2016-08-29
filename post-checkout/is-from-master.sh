#!/usr/bin/env bash

#Some formatting variables
red=$(tput setaf 1)       
magenta=$(tput setaf 203) 
cyan=$(tput setaf 6)      
normal=$(tput sgr0)       

# General patch variables
git_root=`git rev-parse --show-toplevel 2> /dev/null`
git_dir=`git rev-parse --git-dir 2> /dev/null`



############################################
# Warn when trying to create a new branch
# that isn't child of `master` or of the 
# latest tag (for hotfix branches)
############################################
is_from_master() {
  # Enable getting interactive input from user
  exec < /dev/tty

  # Exit early if checking out a file
  [[ $3 == 0 ]] && exit 0

  local branch_name=$(git branch | grep "*" | sed "s/\* //")
  local reflog_message=$(git reflog -1)

  # Ignore branches created by a pull
  [[ $reflog_message =~ "pull" ]] && exit 0

  # Ignore checkouts that are not creating new branches
  git reflog show $branch_name@{0} -1 | grep -q "branch: Created"
  [[ ! $? == 0 ]] && exit 0

  local current_commit=$2
  local last_commit_in_master=$(git rev-parse --short master)
  local latest_tag=$(git rev-list --tags --max-count=1 --abbrev-commit)

  [[ ($current_commit =~ $last_commit_in_master) || ($current_commit =~ $latest_tag) ]] && 
    local from_allowed_branch=true || local from_allowed_branch=false

  if [[ "$from_allowed_branch" == "false" ]]; then
    echo -e "\n${magenta}$branch_name was not created from master.${normal}"
    read -p "Do you want to delete and recreate it from master? (y/N) " answer
    if [[ "$answer" == "y" ]]; then
      echo ""
      git checkout -q master
      git branch -qD $branch_name
      git checkout -qb $branch_name
      echo -e "${magenta}$branch_name${normal} is now a child of master."
    fi
  fi
}; is_from_master $1 $2 $3
