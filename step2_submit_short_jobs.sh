#!/usr/bin/env bash
# Script to submit array job for OpenABM-Covid19 model on Rescomp

source config.sh

# Submit array job
qsub -t 1-2730 -N OpenABM-sas ./jobs/qhh_jobs.sh simcommandlines_qhh.txt