#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 8
#$ -l m_mem_free=15G
#$ -l h_rt=86400
# UGE PARAMETERS END

#Load modules
module load SAMtools
module load Salmon

#set directories
sam_dir=/path/to/sam/dir
bam_dir=/path/to/bam/dir

#move wd to sam_dir
echo "moving wd to ${sam_dir}."
cd "${sam_dir}"

#Dictate samples
Aligned_list=($(find "${sam_dir}" -name "*Aligned.out.sam" -printf "%P\n"))
##Remove "Aligned.out.sam" suffix
Aligned_list_Trim=("${Aligned_list[@]//Aligned.out.sam}")

#Count number of Aligned.out.sam files

Aligned_filesN=$(find "${sam_dir}" -type f -name "*Aligned.out.sam" | wc -l)

echo "Total Aligned.out.sam files: ${Aligned_filesN}"

#Create directory for bam files
if [ ! -d "${bam_dir}" ]; then
	echo "making ${bam_dir}"
		mkdir "$bam_dir"
	else
		echo "${bam_dir} exists"
fi

#Dictate Directories
for ((k=0; k=${Aligned_filesN}; k++)); do

	echo "On sample ${k} of ${Aligned_filesN}"

	sam_name=${sam_dir}/${Aligned_list_Trim[${k}]}
	bam_name=${bam_dir}/${Aligned_list_Trim[${k}]}

	echo "Filtering ${sam_name}Aligned.out.sam"
	echo "sed '/uc.*/d' ${sam_name}Aligned.out.sam > ${sam_dir}/Filtered.${Aligned_list[${k}]}Aligned.out.sam"
	sed '/uc.*/d' ${sam_name}Aligned.out.sam > ${sam_dir}/Filtered.${Aligned_list_Trim[${k}]}Aligned.out.sam

	#Convert to bam

	filtered_bam_file=Filtered.${Aligned_list_Trim[${k}]}Aligned.out.bam
	filtered_sam_file=Filtered.${Aligned_list_Trim[${k}]}Aligned.out.sam

	echo "converting ${filtered_sam_file} to ${filtered_bam_file}"
	echo "samtools view -bS ${sam_dir}/${filtered_sam_file} > ${bam_dir}/${filtered_bam_file}"
	samtools view -bS ${sam_dir}/${filtered_sam_file} > ${bam_dir}/${filtered_bam_file}

	# assemble reads

	echo "Assembling ${filtered_bam_file}"

	echo "salmon quant -t /path/to/transcripts -l ISF -a ${bam_dir}/${filtered_bam_file} -o ${bam_dir}/${Aligned_list_Trim[${k}]}_Aligned_Output/ -p 2"

	salmon quant -t /path/to/transcripts -l ISF -a ${bam_dir}/${filtered_bam_file} -o ${bam_dir}/${Aligned_list_Trim[${k}]}_Aligned_Output/ -p 2

done