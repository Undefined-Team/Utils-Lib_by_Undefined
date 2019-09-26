#!/bin/sh
make fclean
git config --global credential.helper store
git add .
git commit -m "$1"
git pull
git push