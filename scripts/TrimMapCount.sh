#!/usr/bin/env bash

#SBATCH -n 8                        # Number of cores
#SBATCH -N 1                        # Number of nodes
#SBATCH -t 4-12:00                  # Runtime in D-HH:MM
#SBATCH --mem=32G                   # Memory pool for all cores

set -e

# Define variables for project directories
SCRIPTDIR="${1}"
RAWDATADIR="${2}"
DATADIR="${3}"
GENOMEDIR="${4}"
ADAPTER_FILE="${5}"


# Generate genome
shopt -s extglob
fa=$(ls "${GENOMEDIR}"/*@(.fa|.fna|.fasta|.ffn|.faa|.frn|.fa.gz|.fna.gz|.fasta.gz|.ffn.gz|.faa.gz|.frn.gz))
if [[ "${fa}" == *.gz ]]; then fa="${fa%.gz}"; fi
gtf=$(ls "${GENOMEDIR}"/*@(.gtf|.gff|.gtf.gz|.gff.gz))
if [[ "${gtf}" == *.gz ]]; then gtf="${gtf%.gz}"; fi
"${SCRIPTDIR}"/0_GenerateGenome.sh "${GENOMEDIR}" "${fa}" "${gtf}"

for fq in "${RAWDATADIR}"/*R1.fastq*
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
  fq1="${RAWDATADIR}"/"${base}"R1.fastq
  fq2="${RAWDATADIR}"/"${base}"R2.fastq
  trim1="${DATADIR}"/"${base}"R1_trim.fastq
  trim2="${DATADIR}"/"${base}"R2_trim.fastq
  bam_prefix="${DATADIR}"/"${base}"trim_star
  bam="${bam_prefix}"Aligned.sortedByCoord.out.bam
  counts="${DATADIR}"/"${base}"aligned.txt

  echo "_______________________________"
  echo "STEP 1: TRIM ADAPTERS"
  "${SCRIPTDIR}"/1_TrimAdapters.sh "${SCRIPTDIR}" "${DATADIR}" "${base}" "${fq1}" "${fq2}" "${trim1}" "${trim2}" "${ADAPTER_FILE}"
  echo "_______________________________"
  echo "STEP 2: MAP READS TO GENOME"
  "${SCRIPTDIR}"/2_MapToGenome.sh "${DATADIR}" "${GENOMEDIR}" "${base}" "${trim1}" "${trim2}" "${bam_prefix}"
  echo "_______________________________"
  echo "STEP 3: COUNT READS"
  "${SCRIPTDIR}"/3_CountReads.sh "${gtf}" "${base}" "${bam}" "${counts}"

done

echo "________________________________________"
echo "DONE"
echo ""
