# Shell script to pull the latest commit number
# of a git repository and save to file
# 
# Usage:
# save_commit.sh <repo_dir> <github_username> <repo_name> <output_file>
# 
# repo_dir: 
#      the local directory of the repo for which the information is to be extracted
# github_username: 
#      the github user that pulled the repo
# repo_name: 
#      name of the repository on github
# output_file: 
#      file name in which to save this information
# 
# Author: W. Probert (p-robot), 2018

git_dir=$1
github_username=$2
repo_name=$3
output_file=$4

# Pull repository name, latest commit number, and branch name
repo_name=$(cd $git_dir ; echo $(basename -s .git `git config --get remote.origin.url`))
# This will give the parent directory of .git folder: repo_name=$(basename `git rev-parse --show-toplevel`)
latest_commit=$( cd $git_dir ; echo `git rev-parse HEAD` )
branch_name=$( cd $git_dir ; echo `git rev-parse --abbrev-ref HEAD`)

# Save the date the repository was cloned
date_cloned=$(date)

# Save all the information to file
echo "Latest commit" >> $output_file
echo "date cloned: $date_cloned" >> $output_file
echo "username: $github_username" >> $output_file
echo "repo name: $repo_name" >> $output_file
echo "branch name: $branch_name" >> $output_file
echo "commit number: $latest_commit" >> $output_file
echo "" >> $output_file

