#!/usr/bin/env bash

#Some formatting variables
red=$(tput setaf 1)       
magenta=$(tput setaf 203) 
cyan=$(tput setaf 6)      
normal=$(tput sgr0)       

# General patch variables
gitroot=`git rev-parse --show-toplevel 2> /dev/null`
git_dir=`git rev-parse --git-dir 2> /dev/null`



############################################
# Update dependencies if config file changed 
# when merging a remote branch
############################################
sync_deps() {
  local changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

  # Util function to check if file changed, fire command
  has_file() {
    if [[ "${changed_files[*]}" =~ "$1" ]]; then
      inst_deps $1 "$2" $3
    fi
  }

  # Util function to install dependencies
  inst_deps(){
    # Check if we should cd into changed file's directory
    if $3; then
      local file="`echo \"$changed_files\" | grep \"$1\"`"
      local path=`dirname $file`
      cd $gitroot/$path
    fi

    # Run the command(s)
    eval "$2"
  }

  # Check if merging a remote branch
  local reflog_message=$(git reflog -1)
  local merged_branch=$(echo $reflog_message | cut -d" " -f 4 | sed "s/://")

  [[ $reflog_message =~ "pull" ]] || git branch -r | grep --quiet -xE "\s*$merged_branch" 
  if [[ $? == 0 ]]; then
    ## Execute tests to see if files changed
    has_file package.json "npm install && npm prune" true
    has_file jspm.config.js "jspm install && jspm clean" true
    has_file composer.lock "composer install" true
  fi
}; sync_deps
