#!/bin/bash
#$ -cwd -V
#$ -o log
#$ -e log
#$ -P fraser.prjc.low -q short.qc,jeeves.q,gromit.q,brienne.q
#$ -pe shmem 1

module load GSL/2.6-GCC-8.3.0
module load Python/3.7.4-GCCcore-8.3.0
module load R

COMFILE=$1
COM=$(awk "NR==$SGE_TASK_ID" $COMFILE)
read app_ case_ run_ <<<$(echo $COM)
dir_name="date_"$(date +"%F")/case_${case_}/app_${app_}/run_${run_} &&
mkdir -p /well/fraser/users/wpj711/github/simple_agestructered/output/$dir_name &&
python simple_agestructured.py $COM /well/fraser/users/wpj711/github/simple_agestructered/output/$dir_name
output_file_QoT="fraction_quarantine.csv"
output_file_line="aggregated_individual_file.csv"
cd /well/fraser/users/wpj711/github/simple_agestructered/output/$dir_name
Rscript /well/fraser/users/wpj711/github/simple_agestructered/rescomp_gather_QuarantineOverTime_PerRun.R ./ $output_file_QoT
Rscript /well/fraser/users/wpj711/github/simple_agestructered/rescomp_gather_incidence_single_run_linear.R ./ $output_file_line
mv ./individual_file_Run1_t1.csv ./individual_file_Run1.csv
rm ./individual_file_Run1_t*.csv