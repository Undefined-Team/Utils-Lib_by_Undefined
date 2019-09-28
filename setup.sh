#!/bin/bash

# ------------------------------------------------------------- #

# How to use setup.sh ?
# 1 chmod +x setup.sh
# 2 ./setup.sh

# Set the folder path where all lib are
ud_lib_path="$HOME/ud_lib"

# Set the target name of the project
# The source folder in lib folder will have this name. The compiled file name of the project will be lib_ud"NAME".a
name="utils"

# Set project git hub dependences here like this (only repos with same structure work):
# dependences+=("link='https://github.com/tdautreme/Utils-Lib_by_Undefined' && name='utils'")
dependences=()

# ------------------------------------------------------------- #

# 0 - Functions
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'


if [ ! -z "$1" ] && [ $1 != "dep_recursive" ] || [ -z "$1" ] ; then
    dep_recursive=1 
else
    dep_recursive=0
    location=$2
fi

echo "TAMER $1 $dep_recursive"

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
if [[ $dep_recursive == 1 ]] ; then
    info_print "\nCheck if need create main lib env path"
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
            printf "\t"
            error_print "Can't add ${new_path_array[$i]} in ${path_name_array[$i]}"
        fi
        success_print "Env var ${path_name_array[$i]} now contains ${new_path_array[$i]}."
    fi
    # Set env var in bashrc
    if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
        echo "export ${path_name_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'" >> $bashrc_path
        if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
            printf "\t"
            error_print "Can't add export command of ${new_path_array[$i]} in ${path_name_array[$i]} in bashrc file"
        fi
    fi
done
if [[ $dep_recursive == 1 ]] ; then
    printf "\t"
    success_print "All done"
fi

# 2 - Create folder
if [[ $dep_recursive == 1 ]] ; then
    info_print "\nCheck if need create main lib folder"
fi
lib_folder_array=("${ud_lib_path}" "${ud_lib_path}/lib" "${ud_lib_path}/include" "${ud_lib_path}/clone")
for lib_folder in "${lib_folder_array[@]}"; do
	if [ ! -d "$lib_folder" ]; then
        if !(mkdir $lib_folder) ; then
            printf "\t"
            error_print "Can't create $lib_folder folder"
        fi
        printf "\t"
        success_print "$lib_folder folder created"
    fi
done
if [[ $dep_recursive == 1 ]] ; then
    printf "\t"
    success_print "All done"
fi

# 3 - Dependences
if [[ $dep_recursive == 1 ]] ; then
    info_print "\nCheck if need install dependences"
fi
make_dep_name=""
for dep in "${dependences[@]}"; do
    eval $dep
    actual_folder="${ud_lib_path}/clone/$name"
    if [ ! -d "$actual_folder" ]; then
        info_print "--> Trying install [ $name ] dependence"
        printf "\t"
        if !(git clone $link $actual_folder > /dev/null 2>&1) ; then
            error_print "Can't download dependence $name <-> $link"
        fi
        success_print "Dependence was downloaded"
        printf "\t"
        if !(chmod +x "$actual_folder/setup.sh" > /dev/null 2>&1); then
            error_print "Can't chmod dependence"
        fi
        success_print "Dependence was chmoded"
        if !(bash "$actual_folder/setup.sh" "dep_recursive" $actual_folder); then
            printf "\t"
            error_print "Can't install dependence $name <-> $link"
        fi
        printf "\t"
        success_print "Dependence was installed"
    fi
    actual_dep_name=$(cat $actual_folder/setup.sh | grep -m1 name= | cut -d'=' -f 2)
    make_dep_name="$make_dep_name -lud_${actual_dep_name//'"'}"
done
if [[ $dep_recursive == 1 ]] ; then
    printf "\t"
    success_print "All done"
fi

# 4 - Install
if [[ $dep_recursive == 1 ]] ; then
    info_print "\nStart compiling"
    if !(cp res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files to $ud_lib_path/include/ failed"
    fi
    if !(make LIBNAME="libud_$name.a" DEPNAME="$make_dep_name"); then
        error_print "Compilation failed"
    fi
    if !(cp *.a $ud_lib_path/lib/); then
        error_print "Copy compiled files to $ud_lib_path/lib/ failed"
    fi
    printf "\n"
    success_print "Install completed. Shell restarting...\n"
    exec bash
else
    if !(cp $location/res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files from $location/res/include/ to $ud_lib_path/include/ failed"
    fi
    if !(make -C $location LIBNAME="libud_$name.a" DEPNAME="$make_dep_name" > /dev/null 2>&1); then
        error_print "Compilation failed"
    fi
    if !(cp $location/*.a $ud_lib_path/lib/); then
        error_print "Copy compiled files from $location/ to $ud_lib_path/lib/ failed"
    fi
fi
exit 0