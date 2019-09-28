#!/bin/bash

# -------------------------------------------------------------

# How to use setup.sh ?
# 1 chmod +x setup.sh
# 2 ./setup.sh

dependences=()

# Set projet git hub dependences here like this (only repos with same structure work):
# dependences+="https://github.com/tdautreme/Utils-Lib_by_Undefined"

dependences+="https://github.com/tdautreme/Utils-Lib_by_Undefined"

# -------------------------------------------------------------

ud_lib_path="$HOME/ud_lib"

# 0 - Functions
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

function error_print {
    printf "$RED"
    printf "Error: $1$NC\n\n"
    exit 1
}

function success_print {
    printf "$GREEN"
    printf "Success: $1$NC\n"
}

function info_print {
    printf "$BLUE$1$NC\n"
}

# 1 - Set up path in env var
if [ -z "$1" ] ; then
    echo ""
fi
new_path_array=("$ud_lib_path/lib" "$ud_lib_path/include")
path_name_array=("LD_LIBRARY_PATH" "C_INCLUDE_PATH")
path_array=("$LD_LIBRARY_PATH" "$C_INCLUDE_PATH")
path_var_array=(LD_LIBRARY_PATH C_INCLUDE_PATH)
bashrc_path="$HOME/.bashrc"
for i in "${!new_path_array[@]}"; do 
    # Set env var in current shell
    if [[ ! $(env) == *"${new_path_array[$i]}"* ]]; then
        cmd="export ${path_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'"
        eval $cmd
        if [[ ! $(sh -c env) == *"${new_path_array[$i]}"* ]]; then
            error_print "Can't add ${new_path_array[$i]} in ${path_name_array[$i]}"
        fi
        success_print "Env var ${path_name_array[$i]} now contains ${new_path_array[$i]}."
    fi
    # Set env var in bashrc
    if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
        echo "export ${path_name_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'" >> $bashrc_path
        if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
            error_print "Can't add export command of ${new_path_array[$i]} in ${path_name_array[$i]} in bashrc file"
        fi
    fi
done

# 2 - Create folder
lib_folder_array=("${ud_lib_path}" "${ud_lib_path}/lib" "${ud_lib_path}/include" "${ud_lib_path}/clone")
for lib_folder in "${lib_folder_array[@]}"; do
	if [ ! -d "$lib_folder" ]; then
        if !(mkdir $lib_folder) ; then
            error_print "Can't create $lib_folder folder"
        fi
        success_print "$lib_folder folder created"
    fi
done

# 3 - Dependences
for dep in "${dependences[@]}"; do
    actual_folder="${ud_lib_path}/clone/$dep"
    if [ ! -d "$actual_folder" ]; then
        info_print "Try install $dep dependence"
        printf "    "
        if !(git clone $dep $actual_folder > /dev/null 2>&1) ; then
            error_print "Can't download dependence $git_clone_link"
        fi
        success_print "Dependence was downloaded"
        printf "    "
        if !(chmod +x "$actual_folder/setup.sh" > /dev/null 2>&1); then
            error_print "Can't chmod dependence"
        fi
        success_print "Dependence was chmoded"
        if !(bash "$actual_folder/setup.sh" 777); then
            printf "    "
            error_print "Can't install dependence $git_clone_link"
        fi
        printf "    "
        success_print "Dependence was installed"
    fi
done

# 4 - Install
if [ -z "$1" ] ; then
    info_print "\nStart compiling"
    if !(cp res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files to $ud_lib_path/include/ failed"
    fi
    if !(make); then
        error_print "Compilation failed"
    fi
    if !(cp *.a $ud_lib_path/lib/); then
        error_print "Copy compiled files to $ud_lib_path/lib/ failed"
    fi
    exec bash
else
    if !(cp $actual_folder/res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files to $ud_lib_path/include/ failed"
    fi
    if !(make -C $actual_folder > /dev/null 2>&1); then
        error_print "Compilation failed"
    fi
    if !(cp $actual_folder/*.a $ud_lib_path/lib/); then
        error_print "Copy compiled files to $ud_lib_path/lib/ failed"
    fi
fi
exit 0