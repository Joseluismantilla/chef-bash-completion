#!/bin/bash

# Chef tab-completion  v1.0
# Created by Jose Luis Mantilla 2018
# email: joseluismantilla@gmail.com
#
# Features
# chef command tab-completion filled out dinamycally the first time according to the chefdk version and caching on home directory.
# 


_knife_completion() 
{
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    file_caching="/home/$USER/.knife.tmp"

if [[ $prev = "knife" ]]; then
	if [ -f "$file_caching" ]; then
	    base=$(grep -E ^knife $file_caching|awk '{ print $2 }'|uniq )
	    COMPREPLY=( $(compgen -W "${base}" -- ${cur}) )
	else
	    base="$(for x in $(knife |grep -E ^knife| awk '{ print $2 }'|uniq); do echo ${x}; done)"
            COMPREPLY=( $(compgen -W "${base}" -- ${cur}) )
	    knife > $file_caching
	fi
    return 0
else
    case "${prev}" in
        gem)
            opts="install list build help server"
            COMPREPLY=( $(compgen -W "$opts" ${cur}) )
            return 0
        ;;
        * )
	    local running=$(grep $prev $file_caching|grep -E ^knife| awk '{ print $3 }'|uniq) 
            COMPREPLY=( $(compgen -W "${running}" -- ${cur}) )
	        return 0
	    ;;
    esac
fi
}
complete -F _knife_completion knife
