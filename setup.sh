#!/bin/bash

# ------------------------------------------------------------- #

# How to use setup.sh ?
# 1 chmod +x setup.sh
# 2 ./setup.sh {parameter1} {parameter2}...

# Parameter list
# -> fclean (make fclean in current project folder before make)
# -> libclean (remove main lib folder, then all dependencies)

# ------------------------------------------------------------- #

conf_path="conf.csv"

# 0 - Utils
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

if [ ! -z "$1" ] && [ $1 != "dep_recursive" ] || [ -z "$1" ] ; then
    dep_recursive=false
else
    dep_recursive=true
    location=$2
    conf_path="$location/$conf_path"
fi

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
    printf "$BLUE$1$NC\n"
}

# 1 - Get configuration
! $dep_recursive && { info_print "\nGet configuration in conf.csv"; }
dependencies=()
i=0
[ ! -f $conf_path ] && { error_print "Configuration file not found" "\t"; }
while IFS=, read -r col1 col2
do
    col2=${col2//[$'\t\r\n ']}
    if [ $i == 0 ] ; then
        target_name=$col1
        eval "ud_lib_path=$col2"
        i=1
        ! $dep_recursive && { success_print "Set target lib name to [$col1] and main lib path to [$ud_lib_path]" "\t"; }
    else
        dependencies+=("link=$col1 && name=$col2")
        ! $dep_recursive && { success_print "Found dependency [$col2] with git link $col1" "\t"; }
    fi
done < $conf_path
! $dep_recursive && { success_print "All done" "\t"; }

if ! $dep_recursive ; then
    # 2 - Preprocessing
    # ! $dep_recursive && { info_print "\nPreprocessing"; }
    info_print "\nPreprocessing";
    for pparam in "$@"
    do
        if [[ $pparam == "fclean" ]] ; then
            !(make fclean > /dev/null 2>&1) && { error_print "Can't make fclean in current folder" "\t"; }
            success_print "Make fclean in current folder" "\t"
        elif [[ $pparam == "libclean" ]] ; then
            !(rm -rf $ud_lib_path) && { error_print "Can't remove main lib folder" "\t"; }
            success_print "Main lib folder removed" "\t"
        fi
    done

    # 3 - Set up path in env var
    # ! $dep_recursive && { info_print "\nCheck if need create main lib env path"; }
    info_print "\nCheck if need create main lib env path";
    new_path_array=("$ud_lib_path/lib" "$ud_lib_path/include")
    path_name_array=("LIBRARY_PATH" "C_INCLUDE_PATH")
    path_array=("$LIBRARY_PATH" "$C_INCLUDE_PATH")
    path_var_array=(LIBRARY_PATH C_INCLUDE_PATH)
    bashrc_path="$HOME/.bashrc"
    for i in "${!new_path_array[@]}"; do 
        # Set env var in current shell
        if [[ ! $(env) == *"${new_path_array[$i]}"* ]]; then
            cmd="export ${path_var_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'"
            eval $cmd
            if [[ ! $(sh -c env) == *"${new_path_array[$i]}"* ]]; then
                error_print "Can't add ${new_path_array[$i]} in ${path_name_array[$i]}" "\t"
            fi
            success_print "Env var ${path_name_array[$i]} now contains ${new_path_array[$i]}."
        fi
        # Set env var in bashrc
        if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
            echo "export ${path_name_array[$i]}='${new_path_array[$i]}:${path_array[$i]}'" >> $bashrc_path
            if [[ ! $(cat $bashrc_path) == *"${new_path_array[$i]}"* ]]; then
                error_print "Can't add export command of ${new_path_array[$i]} in ${path_name_array[$i]} in bashrc file" "\t"
            fi
        fi
    done
    # ! $dep_recursive && { success_print "All done" "\t"; }
    success_print "All done" "\t"

    # 4 - Create folder
    # ! $dep_recursive && { info_print "\nCheck if need create main lib folder"; }
    info_print "\nCheck if need create main lib folder" 
    lib_folder_array=("${ud_lib_path}" "${ud_lib_path}/lib" "${ud_lib_path}/include" "${ud_lib_path}/clone")
    for lib_folder in "${lib_folder_array[@]}"; do
        if [ ! -d "$lib_folder" ]; then
            !(mkdir $lib_folder) && { error_print "Can't create $lib_folder folder" "\t"; }
            success_print "$lib_folder folder created" "\t"
        fi
    done
    # ! $dep_recursive && { success_print "All done" "\t"; }
    success_print "All done" "\t"
fi

# 5 - Dependencies
! $dep_recursive && { info_print "\nCheck if need install dependencies"; }
make_dep_name=""
make_ar_name=""
for dep in "${dependencies[@]}"; do
    eval $dep
    actual_folder="${ud_lib_path}/clone/$name"
    # if exist pas or update
    if [ ! -d "$actual_folder" ]; then
        info_print "--> Trying install [ $name ] dependence $location"
        # if existe pas
        if !(git clone $link $actual_folder > /dev/null 2>&1) ; then
            error_print "Can't download dependence $name <-> $link" "\t"
        fi
        success_print "Dependence was downloaded" "\t"
        # if update
        # git pull in specific folder
        if !(chmod +x "$actual_folder/setup.sh" > /dev/null 2>&1); then
            error_print "Can't chmod dependence" "\t"
        fi
        success_print "Dependence was chmoded" "\t"
        if !(bash "$actual_folder/setup.sh" "dep_recursive" $actual_folder); then
            error_print "Can't install dependence $name <-> $link" "\t"
        fi
        success_print "Dependence was installed" "\t"
    fi
    # $dep_recursive && new_lib="-lud_${name//'"'}" || new_lib="$ud_lib_path/lib/libud_${name//'"'}.a"
    # new_lib=
    make_dep_name="$make_dep_name -lud_${name//'"'}"
    ! $dep_recursive && { make_ar_name="$make_ar_name $ud_lib_path/lib/libud_${name//'"'}.a"; }

done
! $dep_recursive && { success_print "All done" "\t"; }

# 6 - Install
if ! $dep_recursive ; then
    info_print "\nStart compiling"
    if !(cp res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files to $ud_lib_path/include/ failed"
    fi
    if !(make static LIBNAME="$target_name" DEPNAME="$make_dep_name" ARNAME="$make_ar_name"); then
        error_print "Compilation failed"
    fi
    if !(cp *.a $ud_lib_path/lib/); then
        error_print "Copy compiled files to $ud_lib_path/lib/ failed"
    fi
    success_print "All done\n" "\t"
    success_print "Install completed. Shell restarting...\n"
    exec $SHELL
else
    if !(cp $location/res/include/* $ud_lib_path/include/); then
        error_print "Copy headers files from $location/res/include/ to $ud_lib_path/include/ failed"
    fi
    if !(make -C $location LIBNAME="$target_name" DEPNAME="$make_dep_name" > /dev/null 2>&1); then
        error_print "Compilation failed"
    fi
    if !(cp $location/*.a $ud_lib_path/lib/); then
        error_print "Copy compiled files from $location/ to $ud_lib_path/lib/ failed"
    fi
fi
exit 0