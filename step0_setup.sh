# Script to setup folders for running computational experiments with the
# OpenABM-Covid19 model.  Note: the OpenABM-Covid19 repo is git-cloned 
# using this script.  
# 
# Usage: ./step0_setup.sh
# 
# Created : March 2020
# Author: p-robot

if [[ $# -eq 0 ]]
then
    echo "Error. Include github username as input argument.  Usage: './step0_setup.sh <github_username>' "
    exit 1
fi

# Github-related information
github_username=$1
branch_name="random_replacement_configurable"
#branch_name="master"
repo_name="OpenABM-Covid19"
#repo_host="BDI-pathogens"
repo_host="roberthinch"
output_file="${repo_name}_latest_commit.log"

mkdir -p log input output

ibm_dir="src"
rm -rf $ibm_dir
git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git
(cd $repo_name; git checkout "$commit_number")

# Save the latest commit
./utilities/save_commit.sh $repo_name $github_username $repo_name $output_file

# Remove all files from the src folder except the source code
# (bit of a hack but avoids having nested repos)
# Copy the baseline parameter set to the 'input' folder
mv $repo_name/src ./$ibm_dir
mv $repo_name/tests/data/baseline_parameters.csv ./input/
mv $repo_name/tests/data/baseline_household_demographics.csv ./input/
rm -rf $repo_name

# Compile the code
module load GSL/2.6-GCC-8.3.0
module load Python/3.7.4-GCCcore-8.3.0
(cd $ibm_dir; make clean; make)
