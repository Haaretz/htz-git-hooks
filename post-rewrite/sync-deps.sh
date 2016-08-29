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
# Update dependencies if config file changed 
# when syncing a remote branch
############################################
sync_deps() {

  # Exit early if invoked after an 'amend'
  [[ "$1" = "amend" ]] && exit 0
  
  # Get SHA of original commit before rebase
  local old_sha=$(IFS=" "; set -- `cat <&0 | head -n1`; echo $1)
  
  local changed_files="$(git diff-tree -r --name-only --no-commit-id $old_sha HEAD)"

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
      cd $git_root/$path
    fi

    # Run the command(s)
    eval "$2"
  }


  # Check if we need to update dependencies here
  # based on results of the `post-checkout` hook
  if [[ -f "$git_dir"/update-deps-in-post-rewrite ]]; then
    # Remove file indicating deps should be updated in post-rewrite
    rm -f "$git_dir"/update-deps-in-post-rewrite

    ## Execute tests to see if files changed
    has_file package.json "npm install && npm prune" true
    has_file jspm.config.js "jspm install && jspm clean" true
    has_file composer.lock "composer install" true
  fi
}; sync_deps $1
