#!/bin/bash

# terminal-config script-module sets up general configuration
# for your terminal, e.g prompt format and colors

# get current status of git repo
_parse_git_dirty() {
        local status=`git status 2>&1 | tee`
        local dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        local untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        local ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        local newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        local renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
        local deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
        local bits=''
        if [ "${renamed}" == "0" ]; then
                bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
                bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
                bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
                bits="?${bits}"
        fi
        if [ "${deleted}" == "0" ]; then
                bits="x${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
                bits="!${bits}"
        fi
        if [ ! "${bits}" == "" ]; then
                echo " ${bits}"
        else
                echo ""
        fi
}

# get current branch in git repo
_parse_git_branch() {
        local BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
                local STAT=`_parse_git_dirty`
                echo "[git: ${BRANCH}${STAT}]"
        else
                echo ""
        fi
}

_parse_python_venv() {
        if [ -z $VIRTUAL_ENV ]
        then
                echo ""
        else
                echo "[venv: $(basename $VIRTUAL_ENV)]"
        fi
}

_set_prompt() {
        local RETVAL=$?
        local Red='\[\e[01;31m\]'
        local Green='\[\e[01;32m\]'
        local FancyX='\342\234\227'
        local Checkmark='\342\234\223'
        PS1="\[\033[38;5;7m\][\t\[\033[38;5;15m\]] \[\033[38;5;2m\]\u\\[\033[38;5;165m\]@\[\033[38;5;33m\]\h\[\033[38;5;15m\]:\w \[\033[38;5;11m\]\`_parse_git_branch\` \[\033[38;5;11m\]\`_parse_python_venv\`\n\[\033[38;5;7m\]\\$\[\033[38;5;15m\] "
        if [[ $RETVAL != 0 ]]; then
           PS1="\n$Red$FancyX $PS1"
        else
           PS1="\n$Green$Checkmark $PS1"
        fi
}

_set_prompt_default() {
	local COLOR_PROMPT=no

	case "${TERM}" in
        	xterm-color|*-256color) COLOR_PROMPT=yes;;
	esac
	
	if [[ "${COLOR_PROMPT}" == "yes" ]]; then
	    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	else
	    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
	fi

	# If this is an xterm set the title to user@host:dir
	case "$TERM" in
	xterm*|rxvt*)
	    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	    ;;
	*)
	    ;;
	esac
}

init() {
	# set default prompt
	_set_prompt_default
	# Uncomment to override default prompt
	#PROMPT_COMMAND='_set_prompt && history -a'
}

init
