#!/bin/bash

# ------------------------------------------------------------- #

# How to use setup.sh ?
# 1 chmod +x setup.sh
# 2 ./setup.sh {parameter1} {parameter2}...

# Parameter list
# -> fclean (make fclean in current project folder before make)
# -> libclean (remove main lib folder, then all dependencies)
# -> noupdate (Will not check if update is needed recursively)
# -> nodepmake (Will not make dependencies and sub dependencies)

# ------------------------------------------------------------- #

conf_path="conf"

# 0 - Utils
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

if [ ! -z "$1" ] && [ $1 != "dep_recursive" ] || [ -z "$1" ] ; then
    dep_recursive=false
    location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
else
    dep_recursive=true
    location="$2"
fi
conf_path="$location/$conf_path"
has_set_env=false
noupdate=""
nodepmake=""

function error_print {
    printf "$RED"
    printf "$2Error: $1$NC\n\n"
    exit 1
}

function success_print {
    printf "$GREEN"
    printf "$2Success: $1$NC\n"
}

function info_print {
    printf "$BLUE$2$1$NC\n"
}

function space_trim {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

function csv_param_trim {
    local var="$*"
    var=${var//[$'\t\r\n"']}
    var=$(space_trim "$var")
    var=$(echo "$var" | sed -r 's/[ ]+/_/g')
    echo -n "$var"
}

# 1 - Get configuration
! $dep_recursive && { info_print "\n (1) Get configuration in $conf_path/conf.csv"; }
dependencies=()
i=0
[ ! -f "$conf_path"/conf.csv ] && { error_print "Configuration file not found" "\t"; }
while IFS=, read -r col1 col2
do
    col1=$(csv_param_trim "$col1")
    col2=$(csv_param_trim "$col2")
    # Get name and main lib folder path of the project
    target_name="$col1"
    eval "ud_lib_path=\"$col2\""
    i=1
    ! $dep_recursive && { success_print "Set target lib name to  [ $col1 ] and main lib path to [ $ud_lib_path ]" "\t"; }
done < "$conf_path"/conf.csv
! $dep_recursive && { success_print "All done" "\t"; }

# 2 - Preprocessing
! $dep_recursive && { info_print "\n (2) Preprocessing"; }
for pparam in "$@"
do
    # If fclean parameter detected, fclean project
    if [[ $pparam == "fclean" ]] ; then
        !(make -C "$location" fclean > /dev/null 2>&1) && { error_print "Can't make fclean in $location folder" "\t"; }
        success_print "Make fclean in [ $location ] folder" "\t"
    # If libclean parameter detected, remove main lib folder (Full reset)
    elif [[ $pparam == "libclean" ]] ; then
        !(rm -rf "$ud_lib_path") && { error_print "Can't remove main lib folder" "\t"; }
        success_print "Main lib folder removed" "\t"
    elif [[ $pparam == "noupdate" ]] ; then
        noupdate="noupdate"
    elif [[ $pparam == "nodepmake" ]] ; then
        nodepmake="nodepmake"
    fi
done
! $dep_recursive && { success_print "All done" "\t"; }

# 3 - Check update
! $dep_recursive && { info_print "\n (3) Check if need update"; }
if [[ "$noupdate" != "noupdate" ]] ; then
    if [[ $(git -C "$location" pull) != "Already up to date." ]] > /dev/null 2>&1 ; then
        $dep_recursive && { info_print "[ $target_name ] need to be updated" "\t"; }
        success_print "Files updated" "\t"
    fi
else
    ! $dep_recursive && { success_print "No update parameter detected" "\t"; }
fi
! $dep_recursive && { success_print "All done" "\t"; }

# 4 - Get dependencies
! $dep_recursive && { info_print "\n (4) Get dependencies in $conf_path/dependencies.csv"; }
dependencies=()
i=0
[ ! -f "$conf_path"/dependencies.csv ] && { error_print "Dependencies file not found" "\t"; }
while IFS=, read -r col1 col2
do
    col1=$(csv_param_trim "$col1")
    col2=$(csv_param_trim "$col2")
    # Get dependencies
    dependencies+=("link='$col1' && name='$col2'")
    ! $dep_recursive && { success_print "Found dependency [ $col2 ] with git link [ $col1 ]" "\t"; }
done < "$conf_path"/dependencies.csv
! $dep_recursive && { success_print "All done" "\t"; }

if ! $dep_recursive ; then
    # 5 - Set up path in env var
    info_print "\n (5) Check if need create main lib env path";
    new_path_array=("$ud_lib_path/lib" "$ud_lib_path/include")
    path_name_array=("LIBRARY_PATH" "C_INCLUDE_PATH")
    path_array=("$LIBRARY_PATH" "$C_INCLUDE_PATH")
    path_var_array=(LIBRARY_PATH C_INCLUDE_PATH)
    bashrc_path="$HOME/.bashrc"
    for i in "${!new_path_array[@]}"; do 
        # Set env var in current shell
        if [[ ! $(env) == *"${new_path_array[$i]}"* ]]; then
            has_set_env=true
            cmd="export ${path_var_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'"
            eval $cmd
            if [[ ! $(sh -c env) == *"${new_path_array[$i]}"* ]]; then
                error_print "Can't add [ ${new_path_array[$i]} ] in [ ${path_name_array[$i]} ]" "\t"
            fi
            success_print "Env var [ ${path_name_array[$i]} ] now contains [ ${new_path_array[$i]} ]" "\t"
        fi
        # Set env var in bashrc
        if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
            has_set_env=true
            echo "export ${path_name_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'" >> $bashrc_path
            if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
                error_print "Can't add export command of [ ${new_path_array[$i]} ] in [ ${path_name_array[$i]} ] in bashrc file" "\t"
            fi
        fi
    done
    success_print "All done" "\t"

    # 6 - Create folder
    info_print "\n (6) Check if need create main lib folder" 
    lib_folder_array=("${ud_lib_path}" "${ud_lib_path}/lib" "${ud_lib_path}/include" "${ud_lib_path}/clone")
    for lib_folder in "${lib_folder_array[@]}"; do
        if [ ! -d "$lib_folder" ]; then
            !(mkdir -p "$lib_folder") && { error_print "Can't create  [ $lib_folder ] folder" "\t"; }
            success_print "[ $lib_folder ] folder created" "\t"
        fi
    done
    success_print "All done" "\t"
fi

# 7 - Dependencies
! $dep_recursive && { info_print "\n (7) Check if need install/update dependencies"; }
make_dep_name=""
make_ar_name=""
for dep in "${dependencies[@]}"; do
    eval "$dep"
    actual_folder="${ud_lib_path}/clone/$name"
    # Check if dependency need to be installed
    if [ ! -d "$actual_folder" ]; then
        # Download dependency
        info_print "[ $name ] dependency need to be installed" "\t"
        if !(git clone "$link" "$actual_folder" > /dev/null 2>&1) ; then
            error_print "Can't download dependency [ $name ] <-> [ $link ]" "\t"
        fi
        success_print "Dependency was downloaded" "\t"
        # Chmod dependency
        if !(chmod +x "$actual_folder/setup.sh" > /dev/null 2>&1); then
            error_print "Can't chmod dependency" "\t"
        fi
        success_print "Dependency was chmoded" "\t"
        success_print "Dependency is installing..." "\t"
        if !(bash "$actual_folder/setup.sh" "dep_recursive" "$actual_folder" "$noupdate" "$nodepmake"); then
            error_print "Can't install dependency [ $name ] <-> [ $link ]" "\t"
        fi
    else
        if !(bash "$actual_folder/setup.sh" "dep_recursive" "$actual_folder" "$noupdate" "$nodepmake"); then
            error_print "Can't scan dependency [ $name ] <-> [ $link ]" "\t"
        fi
    fi
        # success_print "Dependency was installed" "\t"
    # Check if dependency need to be Updated
    # elif [ "$noupdate" != "noupdate" ] && [ $(git -C "$actual_folder" pull) != "Already up to date." ] > /dev/null 2>&1 ; then
    #     # Update dependency
    #     info_print "[ $name ] dependency need to be updated" "\t"
    #     if !(bash "$actual_folder/setup.sh" "dep_recursive" "$actual_folder" "fclean"); then
    #         error_print "Can't update dependency [ $name ] <-> [ $link ]" "\t"
    #     fi
    #     success_print "Dependency was updated" "\t"
    # fi
        # Install dependency


    # Create makefile parameter
    make_dep_name="$make_dep_name -lud_${name//'"'}"
    make_ar_name="$make_ar_name $ud_lib_path/lib/libud_${name//'"'}.a"

done
! $dep_recursive && { success_print "All done" "\t"; }

# 8 - Install
if ! $dep_recursive ; then
    info_print "\n (8) Start compiling"
    # Copy headers in main lib folder
    if !(cp "$location"/res/include/* "$ud_lib_path"/include/); then
        error_print "Copy headers files to [ $ud_lib_path/include/ ] failed"
    fi
    # Compil
    # if [[ ${#dependencies[@]} == 0 ]] ; then
    #     if !(make -C "$location" --no-print- LIBNAME="$target_name" DEPNAME="$make_dep_name"); then
    #         error_print "Compilation failed"
    #     fi 
    # elif !(make -C "$location" --no-print-directory static LIBNAME="$target_name" DEPNAME="$make_dep_name" ARNAME="$make_ar_name"); then
    #     error_print "Compilation failed"
    # fi
    if !(make -C "$location" --no-print- LIBNAME="$target_name" DEPNAME="$make_dep_name" ARNAME="$make_ar_name"); then
        error_print "Compilation failed"
    fi 
    # Copy lib in main lib folder
    if !(cp "$location"/*.a "$ud_lib_path"/lib/); then
        error_print "Copy compiled files to [ $ud_lib_path/lib/ ] failed"
    fi
    success_print "All done\n" "\t"
    success_print "Install completed."
    if $has_set_env ; then
        success_print "Shell restarting...\n"
        exec $SHELL
    fi
    printf "\n"
elif [[ "$noupdate" != "noupdate" ]] ; then
    # Copy headers in main lib folder
    if !(cp "$location"/res/include/* "$ud_lib_path"/include/); then
        error_print "Copy headers files from [ $location/res/include/ ] to [ $ud_lib_path/include/ ] failed"
    fi
    # Compil
    # if [[ ${#dependencies[@]} == 0 ]] ; then
    #     if !(make -C "$location" LIBNAME="$target_name" DEPNAME="$make_dep_name" > /dev/null 2>&1); then
    #         error_print "Compilation failed"
    #     fi
    # else
    #     if !(make -C "$location" static LIBNAME="$target_name" DEPNAME="$make_dep_name" > /dev/null 2>&1); then
    #         error_print "Compilation failed"
    #     fi
    # fi
    if !(make -C "$location" LIBNAME="$target_name" DEPNAME="$make_dep_name" ARNAME="$make_ar_name"); then
        error_print "Compilation failed"
    fi > /dev/null 2>&1
    # Copy lib in main lib folder
    if !(cp "$location"/*.a "$ud_lib_path"/lib/); then
        error_print "Copy compiled files from [ $location/ ] to [ $ud_lib_path/lib/ ] failed"
    fi
fi
exit 0