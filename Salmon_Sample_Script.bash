#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 8
#$ -l m_mem_free=15G
#$ -l h_rt=86400
# UGE PARAMETERS END

#Load modules
module load SAMtools
module load Salmon

#Select batch number
n=1

#set directories
sam_dir="/path/to/sam_${n}/dir"
bam_dir="/path/to/bam_${n}/output/dir"

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
for ((k=0; k<=Aligned_filesN; k++)); do

	echo "On sample ${k} of ${Aligned_filesN}"

	sam_name=${sam_dir}/${Aligned_list_Trim[${k}]}Aligned.out.sam
	bam_name=${bam_dir}/${Aligned_list_Trim[${k}]}Aligned.out.bam

	#Convert to bam
	echo "converting ${sam_name} to ${bam_name}"
	echo "samtools view -bS ${sam_name} > ${bam_name}"
	samtools view -bS ${sam_name} > ${bam_name}

	# assemble reads

	echo "Assembling ${bam_name}"

	echo "salmon quant -t /path/to/transcripts -g /path/to/gtf -l A -a ${bam_name} -o ${bam_dir}/${Aligned_list_Trim[${k}]}_Aligned_Output/"

	salmon quant -t /path/to/transcripts -g /path/to/gtf -l A -a ${bam_name} -o "${bam_dir}/${Aligned_list_Trim[${k}]}_Aligned_Output/"

done