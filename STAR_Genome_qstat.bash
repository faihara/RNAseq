#!/bin/bash

# UGE PARAMETERS
#$ -pe smp 8
#$ -l m_mem_free=15G
#$ -l h_rt=86400
# UGE PARAMETERS END

#Set directories & files
WD_name=/path/to/wd
GenomeOutDIR=/path/to/output/dir
GenomeFasta=/path/to/reference
GenomeGTF=/path/to/gtf

#Go to WD
cd "${WD_name}"

#Run Genome generation
STAR --runThreadN 8 --runMode genomeGenerate -- genomeDir ${GenomeOutDIR} --genomeFastaFiles ${GenomeFasta} --sjdbGTFfile ${GenomeGTF} --sjdbOverhang 99