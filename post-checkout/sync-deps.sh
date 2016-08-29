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
# when rebasing a remote branch
#
# Sets up indication for `post-rewrite` hook
# in case of merge conflicts
############################################

sync_deps() {
  local changed_files="$(git diff-tree -r --name-only --no-commit-id HEAD@{1} HEAD)"

  local prev_head=$1
  local new_head=$2
  [[ $3 == 1 ]] && co_type="branch" || co_type="file"

  local prev_branch=`git name-rev --name-only $prev_head`
  local new_branch=`git name-rev --name-only $new_head`

  local dir_rebase_merge="$git_dir"/rebase-merge
  local dir_rebase_apply="$git_dir"/rebase-apply


  # Check if file changed, fire command
  has_file() {
    if [[ "${changed_files[*]}" =~ "$1" ]]; then
      inst_deps $1 "$2" $3
    fi
  }


  #Install dependencies
  inst_deps() {
    sleep .1

    # Check if we are mid-rebase
    [[ -d "$dir_rebase_apply" ]] && local rebase_conflict=true || local rebase_conflict=false
    [[ -d "$dir_rebase_merge" && -f "$dir_rebase_merge/interactive" ]] && local is_int_rebase=true || local is_int_rebase=false

    if [[ $rebase_conflict == true || $is_int_rebase == true ]]; then

      # Indicate that dependencies should be updated in `post-rewrite` 
      # if rebasing from a remote
      if [[ $rebase_conflict == true && ($new_branch =~ "remotes/" || $prev_branch =~ "remotes/")  ]]; then
        touch "$git_dir"/update-deps-in-post-rewrite
      fi

      # Install dependencies otherwise
    else
      if [[ $new_branch =~ "remotes/" || $prev_branch =~ "remotes/"  ]]; then
        exec < /dev/tty
        echo -e "\npost-checkout"
        echo "new: $new_branch"
        echo "prev: $prev_branch"

        if $3; then
          local file="`echo \"$changed_files\" | grep \"$1\"`"
          local path=`dirname $file`
          cd $git_root/$path
        fi

        # Run the command(s)
        eval "$2"
      fi
    fi
  }


  # Execute tests to see if files changed
  has_file package.json "npm install && npm prune" true &
  has_file jspm.config.js "jspm install && jspm clean" true &
  has_file composer.lock "composer install" true &
}; sync_deps $1 $2 $3
