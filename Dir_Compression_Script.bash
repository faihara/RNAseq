#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 8
#$ -l m_mem_free=15G
#$ -l h_rt=86400
# UGE PARAMETERS END

WD_name=/path/to/wd
OutDIR=/path/to/output/dir

cd "${WD_name}"

#Set dir list
DIR_list=($(find "${WD_name}" -name "hervquant_output_GBM_*" -printf "%P\n"))
echo "${DIR_list[@]}"

#Count number of Aligned.out.sam files

DIR_listN=$(find "${WD_name}" -name "hervquant_output_GBM_*" | wc -l)

echo "Total Aligned.out.sam files: ${DIR_listN}"

# Prompt for user confirmation
read -p "Are you sure you want to proceed? (y/n): " response

# Check user response
if [[ "$response" =~ ^[yY]$ ]]; then
    echo "Proceeding with compression..."

        #Check for OutDIR presence
    if [ ! -d "${OutDIR}" ]; then
	    echo "making ${OutDIR}"
	    mkdir "${OutDIR}"
    fi

    for ((k=0; k<${DIR_listN}; k++)); do
        echo "Compressing ${k} of ${DIR_listN}"
        Target_DIR=${WD_name}/${DIR_list[${k}]}
        Output_Name=${OutDIR}/${DIR_list[${k}]}.tar.gz

        echo "tar -czf ${Output_Name} ${Target_DIR}"
        tar -czf ${Output_Name} ${Target_DIR}
    done

else
    echo "Operation cancelled."
    exit 0  # Exit the script or perform any other action based on your specific requirements.
fi