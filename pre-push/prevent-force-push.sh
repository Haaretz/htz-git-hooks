#!/usr/bin/env bash

#Some formatting variables
red=$(tput setaf 1)       
magenta=$(tput setaf 203) 
cyan=$(tput setaf 6)      
normal=$(tput sgr0)       

# General patch variables
git_root=`git rev-parse --show-toplevel 2> /dev/null`
git_dir=`git rev-parse --git-dir 2> /dev/null`

##############################################
# Protect branches specified in the $protected
# variable from force pushes, which can mess
# up history.
##############################################
prevent_force() {
  # Exit early if pushing to a remote that isn't 'origin'
  [[ $1 != "origin"  ]] && exit 0

  # Protected branches, set up as many as you'd like
	local protected="(master|dev|release/.+)"

  current_branch=`git rev-parse --abbrev-ref HEAD`
  push_command=`ps -ocommand= -p $PPID`
  is_destructive="force|delete|-f"
  will_delete_protected=':'$protected

  if [[ "$current_branch" =~ $protected && "$push_command" =~ $is_destructive ]] || \
     [[ "$push_command" =~ $is_destructive && $push_command =~ $protected ]] || \
     [[ $push_command =~ $will_delete_protected ]]
	then
    local branch_name="$(echo $push_command | grep -ohE "$protected")" 
    echo -e "\n${cyan}[Policy]${normal} Deleting or force pushing to the ${red}$branch_name${normal} branch of $1 is forbidden\n"

    exit 1
  fi

  exit 0
}; prevent_force $1 $2
