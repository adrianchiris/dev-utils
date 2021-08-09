#!/bin/bash

# This script-module offers helper functionality
# to work with git, when branching and rebases are needed
# it assumes the upstream remote repository is named "origin"
# and the remote forked repo is named "forked".
# These should be adjusted in your git repository .git/config file
# alternatively a new git-clone-repo method can be added to do this for you
# origin/forked remote repository names may be changed by overriding
# GS_REMOTE_ORIGIN, GS_REMOTE_FORKED shell variables.

init() {
	GS_REMOTE_ORIGIN=${GS_REMOTE_ORIGIN:-"origin"}
	GS_REMOTE_FORKED=${GS_REMOTE_FORKED:-"forked"}
	# Git autocompletion
	if [[ -a "~/.git-completion.bash" ]]; then
		source ~/.git-completion.bash
	fi
	# Setup useful git Aliases
	alias gca='git commit --amend --no-edit'
	alias gce='git commit --amend'
	alias gri='git rebase --interactive $1'
	alias grc='git rebase --continue'
	alias gsp='git stash && git pull --rebase && git stash pop'
	alias gpf='git push --force-with-lease ${GS_REMOTE_FORKED} `git rev-parse --abbrev-ref HEAD`'
}

# git-checkout-pr checks out a PR from origin
git-checkout-pr() {
    if [[ ${#} -eq 0 ]]; then
            echo "Usage: git-checkout-pr <PR-number> [branch-name]"
            return
    fi
    git fetch ${GS_REMOTE_ORIGIN} refs/pull/$1/head
    local branch=${2:-pull/$1}
    git checkout -b $branch FETCH_HEAD
}

# git-branch-del deletes local branches provided, -r flag will delete remote branch from remote named forked
git-branch-del() {
    if [[ $# -eq 0 || $# -eq 1 && "$1" == "-r" ]]; then
            echo "Usage: git-branch-del [-r] <branch-name> [branch_name ...]"
            return
    fi
    local delete_remote=false

    if [[ "$1" == "-r" ]]; then
            delete_remote=true
            shift
    fi

    local current_branch=`git rev-parse --abbrev-ref HEAD`
    for var in "$@"; do
            if [[ "$var" == "$current_branch" ]]; then
                    echo "Deleting current branch, switching to master."
                    git checkout master
            fi
    done
    for var in "$@"; do
            echo "Deleting branch $var"
            git branch -D $var
            if [[ "$delete_remote" == true ]]; then # Delete remote branch as well
                    echo "Deleting branch $var from remote"
                    git push ${GS_REMOTE_FORKED} --delete $var
            fi
    done
}

init