#!/usr/bin/env bash

#SBATCH -n 8                        # Number of cores (-n)
#SBATCH -N 1                        # Ensure that all cores are on one Node (-N)
#SBATCH -t 8-12:00                  # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --mem=32G                   # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --job-name=TrimMapCount     # Short name for the job
#SBATCH --output=%j.TrimMapCount.log


set -e
unset PYTHONPATH

# Avoid dumping too much temporary data into system tmp directory
export TMPDIR=/storage/fazal/tmp
export TEMP=/storage/fazal/tmp
export TMP=/storage/fazal/tmp

# Activate environment
export PATH=/storage/fazal/software/1_TrimMapCount/venv/bin:"${PATH}"

# Define variables for project directories
PROJECTDIR=/storage/fazal/pipelines/TrimMapCount/scripts
GENOMEDIR=/storage/fazal/genome/human/GRCh38.104
DATADIR="${1}"
OUTPUTDIR="${2}"


# Unzip gtf
gtf="${GENOMEDIR}"/Homo_sapiens.GRCh38.104.gtf
[ -f "${gtf}" ] || gunzip "${gtf}.gz"

for fq in "${DATADIR}"/*R1.fastq*
do
  # Echo for debugging/reporting to the screen
  echo "________________________________________"
  echo "Working with file ${fq}"
  
  # Extract base name of file (without path and .fastq extension)
  if [[ "${fq}" == *.gz ]] 
  then
    base=$(basename "${fq}" R1.fastq.gz)
  else
    base=$(basename "${fq}" R1.fastq)
  fi

  # Define variables for filenames
  fq1="${DATADIR}"/"${base}"R1.fastq
  fq2="${DATADIR}"/"${base}"R2.fastq
  trim1="${OUTPUTDIR}"/"${base}"R1_trim.fastq
  trim2="${OUTPUTDIR}"/"${base}"R2_trim.fastq
  bam_prefix="${OUTPUTDIR}"/"${base}"trim_star
  bam="${bam_prefix}"Aligned.sortedByCoord.out.bam
  txt="${OUTPUTDIR}"/"${base}"aligned.txt

  # Trim reads
  echo "_______________________________"
  echo "STEP 1: TRIM READS"
  if [[ -f "${OUTPUTDIR}"/"${base}"R1_trim.fastq.trimlog ]]
  then
    echo "Trim reads in ${base} already complete; skipping re-trimming."
  else
    echo "Trimming reads in ${base}. Estimated time for trimming is 30 minutes."
    # Unzip fastq
    echo "Unzipping fastq files..."
    [ -f "${fq1}" ] || gunzip "${fq1}".gz
    [ -f "${fq2}" ] || gunzip "${fq2}".gz
    # Trim
    perl "${PROJECTDIR}"/icSHAPE/scripts/trimming.pl \
      -1 "${fq1}" \
      -2 "${fq2}" \
      -p "${trim1}" \
      -q "${trim2}" \
      -l 0 \
      -t 0 \
      -c phred33 \
      -a "${PROJECTDIR}"/icSHAPE/data/adapter/adapter.fa \
      -m 36
    # Zip fastqs
    echo "Zipping fastq files..."
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    [ -f "${trim2}.gz" ] || gzip "${trim2}"
    [ -f "${fq1}.gz" ] || gzip "${fq1}"
    [ -f "${fq2}.gz" ] || gzip "${fq2}"
  fi

  # Map/align to genome
  echo "_______________________________"
  echo "STEP 2: MAP READS TO GENOME"
  if [[ -f "${OUTPUTDIR}"/"${base}"trim_starLog.final.out ]]
  then
    echo "Map reads in ${base} already complete; skipping re-mapping."
  else
    echo "Mapping reads in ${base}. Estimated time for mapping is 30 minutes."
    # Make sure fastqs are zipped
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    [ -f "${trim2}.gz" ] || gzip "${trim2}"
    [ -f "${fq1}.gz" ] || gzip "${fq1}"
    [ -f "${fq2}.gz" ] || gzip "${fq2}"
    # Map
    STAR \
      --genomeDir "${GENOMEDIR}"/star \
      --runThreadN 8 \
      --readFilesIn "${trim1}".gz "${trim2}".gz \
      --outSAMtype BAM SortedByCoordinate \
      --outBAMsortingThreadN 1 \
      --outFileNamePrefix "${bam_prefix}" \
      --readFilesCommand zcat  # append this option for .gz input
  fi

  # Get counts
  echo "_______________________________"
  echo "STEP 3: COUNT READS"
  if [[ -s "${txt}" ]]
  then
    echo "Count reads in ${base} already complete; skipping re-counting."
  else
    echo "Counting reads in ${base}. Estimated time for counting is 90 minutes."
    # Make sure gtf and bam are unzipped
    [ -f "${gtf}" ] || gunzip "${gtf}.gz"
    [ -f "${bam}" ] || gunzip "${bam}.gz"
    # Count
    python \
      -m HTSeq.scripts.count \
      --stranded=reverse \
      --nonunique=all \
      --format=bam \
      --order=pos \
      --idattr=gene_id "${bam}" "${gtf}" > "${txt}"
    # Zip bam
    echo "Zipping bam file..."
    [ -f "${bam}.gz" ] || gzip "${bam}"
  fi
done

# Zip gtf
# [ -f "${gtf}.gz" ] || gzip "${gtf}"

echo "________________________________________"
echo "DONE"
echo ""
