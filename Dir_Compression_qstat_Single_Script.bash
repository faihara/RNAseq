#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 8
#$ -l m_mem_free=15G
#$ -l h_rt=86400
# UGE PARAMETERS END

WD_name=/path/to/wd
OutDIR=/path/to/output/dir

cd "${WD_name}"

# Set dir list
DIR_list=("hervquant_output_GBM_4_bam")
echo "${DIR_list}"

# Compress DIR_list
Target_DIR="${WD_name}/${DIR_list}"
Output_Name="${OutDIR}/${DIR_list}.tar.gz"
echo "tar -czf ${Output_Name} ${Target_DIR}"
tar -czf "${Output_Name}" "${Target_DIR}"