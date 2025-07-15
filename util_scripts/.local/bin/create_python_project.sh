#!/bin/bash
# ". ./create_python_project.sh <new_folder_name>" 

# Argument validation check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <new_folder_name>"
    exit 1
fi


# The main code
new_folder_name=$1
echo "creating python project: $new_folder_name";

mkdir $new_folder_name
cd $new_folder_name

python -m venv .
source ./bin/activate

mkdir src
