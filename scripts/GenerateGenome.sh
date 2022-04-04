#!/usr/bin/env bash

#SBATCH -n 8                        # Number of cores (-n)
#SBATCH -N 1                        # Ensure that all cores are on one Node (-N)
#SBATCH -t 0-12:00                  # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --mem=128G                  # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --job-name=GenerateGenome   # Short name for the job
#SBATCH --output=%j.GenerateGenome.log


set -e
unset PYTHONPATH

# Avoid dumping too much temporary data into system tmp directory
export TMPDIR=/storage/fazal/tmp
export TEMP=/storage/fazal/tmp
export TMP=/storage/fazal/tmp

# Activate environment
export PATH=/storage/fazal/software/1_TrimMapCount/venv/bin:"${PATH}"

# Define variables for files
GENOMEDIR=/storage/fazal/genome/human/GRCh38.104
hg38_fa="${GENOMEDIR}"/"Homo_sapiens.GRCh38.dna.primary_assembly.fa"
hg38_gtf="${GENOMEDIR}"/"Homo_sapiens.GRCh38.104.gtf"


# Unzip files (if zipped)
[ -f "${hg38_fa}" ] || gunzip "${hg38_fa}".gz
[ -f "${hg38_gtf}" ] || gunzip "${hg38_gtf}".gz

# Generate genome index
STAR \
  --runThreadN 8 \
  --runMode genomeGenerate \
  --genomeDir "${GENOMEDIR}"/star \
  --genomeFastaFiles "${hg38_fa}" \
  --sjdbGTFfile "${hg38_gtf}" \
  --limitGenomeGenerateRAM 120000000000 \
  --limitSjdbInsertNsj 4000000

# Zip files to save space
gzip "${hg38_fa}"
# gzip "${hg38_gtf}"
