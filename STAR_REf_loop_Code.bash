#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 16
#$ -l m_mem_free=10G
#$ -l h_rt=86400
# UGE PARAMETERS END

#Load module
module load STAR

#Select batch number
n=1

# Path to the sample list files
sample_input_list="/path/to/sample_${n}/list"
sample_output_list="/path/to/patient_${n}/list"

#Dictate Directories
Study_OutDIR="/path/to/output/dir_${n}"
Hervquant_refDIR=/path/to/Hervquant/ref/dir
ReadFilesDIR=/path/to/fastq

#Check for Study_OutDIR presence
if [ ! -d "${Study_OutDIR}" ]; then
	echo "making ${Study_OutDIR}"
	mkdir "${Study_OutDIR}"
    else
    echo "${Study_OutDIR} exists."
fi
c
#create tmp copy
echo "moving wd to ${Study_OutDIR}."
cd ${Study_OutDIR}

# Read the sample names from the file and execute actions
while IFS= read -r sample_input && IFS= read -r sample_output <&3 ; do
    
    #Set tar file location
    tar_directory=${ReadFilesDIR}/${sample_input}
    tar_directory_clean=$(echo "${tar_directory}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') #Clean up any white space before or after a string from sample_input_list
    tar_file_name=$(find "${tar_directory_clean}" -name "*.tar.gz" -type f -print -quit)

    #Check command
    echo "Extracting fastqs in ${tar_file_name} to ${Study_OutDIR}."
    echo "tar -xvzf ${tar_file_name} -C ${Study_OutDIR}"

    #Extract to ${Study_OutDIR}
    tar -xvzf "${tar_file_name}" -C "${Study_OutDIR}"

    #Check to makes sure tar file is extracted
if [ ${tar_exit_status} -ne 0 ]; then
    echo "Error extracting tarball: ${tar_file_name}"
    continue
fi

    ls -l

    #Assign fastq file names
    file_1=$(find -name "*_1.fastq" -printf "%P\n")
    file_2=$(find -name "*_2.fastq" -printf "%P\n")

    #Create pathway for fastq input files
    fastq_file_1="${Study_OutDIR}/${file_1}"
    fastq_file_2="${Study_OutDIR}/${file_2}"

    #Create time gap to ensure all file names are recorded.
    if [ -z "${fastq_file_2}" ]
    then
        sleep 5s
    else
        echo "${fastq_file_2} is NOT NULL"
    fi

    #Run STAR
    echo "Running alignment on ${sample_input}"
    echo "STAR --runThreadN 16 --outFileNamePrefix ${Study_OutDIR}/${sample_output} --outFilterMultimapNmax 10 --outFilterMismatchNmax 7 --genomeDir ${Hervquant_refDIR} --readFilesIn ${fastq_file_1} ${fastq_file_2}"
    STAR --runThreadN 16 --outFileNamePrefix ${Study_OutDIR}/${sample_output} --outFilterMultimapNmax 10 --outFilterMismatchNmax 7 --genomeDir ${Hervquant_refDIR} --readFilesIn ${fastq_file_1} ${fastq_file_2}

    #Cleanup
    echo "Removing ${fastq_file_1} from ${Study_OutDIR}"
    rm ${fastq_file_1}

    echo "Removing ${fastq_file_2} from ${Study_OutDIR}"
    rm ${fastq_file_2}
done < "$sample_input_list" 3<"$sample_output_list"