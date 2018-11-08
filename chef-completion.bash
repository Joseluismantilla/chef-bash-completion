#!/bin/bash

# Chef tab-completion  v1.0
# Created by Jose Luis Mantilla 2018
# email: joseluismantilla@gmail.com
#
# Features
# chef command tab-completion 
# If you want to use it with dynamical values, exchange the lines 19 by 20 and 31 by 32.
#

_chef_completion() 
{
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

if [[ $prev == "chef" ]]; then
	base="exec env gem generate shell-init install update push push-archive show-policy diff provision export clean-policy-revisions clean-policy-cookbooks delete-policy-group delete-policy undelete describe-cookbook"
	#base=$(for x in $(chef |grep -Ev 'chef|Usage|Available'|grep -Ev '^[[:space:]]*$' | awk '{ print $1 }' ); do echo ${x} ; done)
    COMPREPLY=( $(compgen -W "${base}" -- ${cur}) )
    return 0
else
    case "${prev}" in
        gem)
            opts="install list build help server"
            COMPREPLY=( $(compgen -W "$opts" ${cur}) )
            return 0
        ;;
        generate )
	    local running="app attribute Available cookbook file generator helpers lwrp policyfile recipe repo resource template"
	    #local running=$(for x in $(chef $prev | grep -v Usage| grep -ie generat | awk '{ print $1 }'); do echo ${x} ; done) 
            COMPREPLY=( $(compgen -W "${running}" -- ${cur}) )
	    return 0
	;;
        *)
        ;;
    esac
fi
}
complete -F _chef_completion chef
