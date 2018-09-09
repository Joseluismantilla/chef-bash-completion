#!/bin/bash
#
# Bash completion for Knife 0.10+
#

if [ $(uname) = "Darwin" ]; then
    SED="gsed"
else
    SED="sed"
fi

_escape() {
    echo "$1" | $SED -r s'/([^a-zA-Z0-9])/\\\1/g'
}

_flatten_command() {
    local cur
    _get_comp_words_by_ref cur
    echo ${COMP_WORDS[*]} |  $SED -r -e 's/[[:space:]]-[[:alnum:]-]+//g' \
        -e "s/[[:space:]]*$(_escape $cur)\$//" -e 's/[[:space:]]+/_/g'
}

# Helper functions to get lists of
# Unfortunately knife pollutes STDOUT
# on errors, making this more complicated then it needs to be.

_output_on_success() {
    local out
    out=$($* 2>/dev/null)
    [ $? -eq 0 ] && echo $out
}

_chef_nodes() {
    _output_on_success knife node list
}

_chef_local_cookbooks() {
    test -d cookbooks && find cookbooks -maxdepth 1 -type d -print0 | xargs -0 -n1 basename
}

_chef_remote_cookbooks() {
    _output_on_success knife cookbook list | awk '{print $1}'
}

_chef_clients() {
    _output_on_success knife client list
}

_chef_roles() {
    _output_on_success knife role list
}

_chef_environments() {
    _output_on_success knife environment list
}

_chef_data_bags() {
    _output_on_success knife data bag list
}

_chef_data_bag_items() {
    local bag
    bag=$1
    _output_on_success knife data bag show $bag
}

_chef_tags() {
    local node
    node=$1
    _output_on_success knife tag list $node
}

_knife() {
    local cur prev opts candidates
    _get_comp_words_by_ref cur prev

    opts="--server-url --chef-zero-host --chef-zero-port \
	--key --color --config --config-option --defaults --disable-editing \
	--editor --environment --fips --format --listen --local-mode \
    --environment --format --no-color --no-editor --no-fips --no-listen \
	--user --print-after --profile --verbose --version --yes --help"

    if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
    fi

    case $(_flatten_command) in
        knife)
            candidates="bootstrap client config configure cookbook data delete deps diff download edit environment exec help list node recipe role search show ssl ssh status supermarket tag upload user raw rehash xargs"
            ;;
        knife_client)
            candidates="create delete edit key list reregister show bulk"
            ;;
        knife_client_bulk)
            candidates="delete"
            ;;
        knife_client_key)
            candidates="create delete edit list show"
            ;;
        knife_config)
            candidates="get"
            ;;
        knife_configure)
            candidates="client"
            ;;
        knife_cookbook)
            candidates="bulk delete download list metadata show test upload site"
            ;;
        knife_cookbook_bulk)
            candidates="delete"
            ;;
        knife_cookbook_metadata)
            candidates="from"
            ;;
        knife_cookbook_site)
            candidates="download install list search share show unshare"
            ;;
        knife_data)
            candidates="bag"
            ;;
        knife_data_bag)
            candidates="create delete edit from list show"
            ;;
        knife_data_bag_from)
            candidates="file"
            ;;
        knife_environment)
            candidates="compare create delete edit from list show"
            ;;
        knife_environment_from)
            candidates="file"
            ;;
        knife_exec)
            candidates="[SCRIPT]"
            ;;
        knife_recipe)
            candidates="list"
            ;;
        knife_role)
            candidates="bulk create delete edit env_run_list from list run_list show"
            ;;
        knife_role_bulk)
            candidates="delete"
            ;;
        knife_role_env_run_list)
            candidates="add clear remove replace set"
            ;;
        knife_role_from)
            candidates="file"
            ;;
        knife_role_run_list)
            candidates="add clear remove replace set"
            ;;
        knife_tag)
            candidates="list delete create"
            ;;
        knife_node)
            candidates="bulk create delete edit environment from list policy run_list show"
            ;;
        knife_node_bulk)
            candidates="delete"
            ;;
        knife_node_environment)
            candidates="set"
            ;;
        knife_node_from)
            candidates="file"
            ;;
        knife_node_policy)
            candidates="set"
            ;;
        knife_node_run_list)
            candidates="add remove set"
            ;;
        knife_osc_user)
            candidates="create delete edit list register show"
            ;;
        knife_search)
            candidates="client environment node role"
            ;;
        knife_tag)
            candidates="list delete create"
            ;;
        knife_ssl)
            candidates="check fetch"
            ;;
        knife_role)
            candidates="edit show delete create from_file list bulk_delete"
            ;;
        knife_status)
            candidates="[QUERY] --hide-by-mins --hide-healthy --long --medium --run-list"
            ;;
        knife_supermarket)
            candidates="download install list search share show unshare"
            ;;
        knife_tag)
            candidates="list delete create"
            ;;
        knife_user)
            candidates="create delete edit key list reregister show"
            ;;
        knife_user_key)
            candidates="create delete edit list show"
            ;;
        knife_node_show|knife_node_edit|knife_node_delete)
            candidates=$(_chef_nodes)
            ;;
        knife_node_run_list)
            candidates="add remove"
            ;;
        knife_node_run_list_add|knife_node_run_list_remove)
            candidates=$(_chef_nodes)
            ;;
        knife_client_show|knife_client_edit|knife_client_delete)
            candidates=$(_chef_clients)
            ;;
        knife_cookbook_upload|knife_cookbook_test|knife_cookbook_metdata)
            candidates=$(_chef_local_cookbooks)
            ;;
        knife_cookbook_download|knife_cookbook_delete|knife_cookbook_show)
            candidates=$(_chef_remote_cookbooks)
            ;;
        knife_environment_delete|knife_environment_show|knife_environment_edit)
            candidates=$(_chef_environments)
            ;;
        knife_data_bag_show|knife_data_bag_create|knife_data_bag_delete)
            candidates=$(_chef_data_bags)
            ;;
        knife_data_bag_show_*|knife_data_bag_create_*|knife_data_bag_delete_*)
            candidates=$(_chef_data_bag_items $prev)
            ;;
        knife_role_show|knife_role_edit|knife_role_delete)
            candidates=$(_chef_roles)
            ;;
        knife_tag_create|knife_tag_list|knife_tag_delete)
            candidates=$(_chef_nodes)
            ;;
        knife_tag_delete_*)
            candidates=$(_chef_tags $prev)
            ;;
        *)
            _filedir
            return 0;
            ;;
    esac
    COMPREPLY=($(compgen -W "${candidates}" -- ${cur}))
    return 0
}

complete -F _knife knife
