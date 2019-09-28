#!/bin/bash

# Use setup.sh
# chmod +x setup.sh
# ./setup.sh

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
        cmd="export ${path_var_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'"
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

# if $(./error.sh) ; then
#     echo work
# else
#     echo not work
# fi
# echo $(./error.sh)

# 3 - Dependences
dep_prefix="https://github.com/tdautreme/"
dep_suffix="-Lib_by_Undefined"
dependences=("Utils")
for dep in "${dependences[@]}"; do
    actual_folder="${ud_lib_path}/clone/$dep"
    git_clone_link="$dep_prefix$dep$dep_suffix"
    if [ ! -d "$actual_folder" ]; then
        info_print "Try install $dep dependence"
        printf "    "
        if !(git clone $git_clone_link $actual_folder > /dev/null 2>&1) ; then
            error_print "Can't download dependence $git_clone_link"
        fi
        success_print "Dependence was downloaded"
        printf "    "
        if !(chmod +x "$actual_folder/setup.sh" > /dev/null 2>&1); then
            error_print "Can't chmod dependence"
        fi
        success_print "Dependence was chmoded"
        printf "    "
        if !(bash "$actual_folder/setup.sh" 1); then
            error_print "Can't install dependence $git_clone_link"
        fi
        success_print "Dependence was installed"
    fi
done
# echo "wtf1"

# printf "\n\n\n"

# 4 - Install
cp res/include/* $ud_lib_path/include/
if [ -z "$1" ] ; then
    make
    exec bash
else
    make > /dev/null 2>&1
fi
cp *.a $ud_lib_path/lib/
exit 0