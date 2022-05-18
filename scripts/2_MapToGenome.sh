
DATADIR="${1}"
GENOMEDIR="${2}"
base="${3}"
trim1="${4}"
trim2="${5}"
bam_prefix="${6}"

if [[ -f "${DATADIR}"/"${base}"trim_starLog.final.out ]]
then
  echo "Map reads in ${base} already complete; skipping re-mapping."
else
  echo "Mapping reads in ${base}. Estimated time for mapping is 5-15 minutes."

  if [[ -f "${trim2}" ]] || [[ -f "${trim2}".gz ]]
  then
    # Paired-end data
    # Make sure fastqs are zipped
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    [ -f "${trim2}.gz" ] || gzip "${trim2}"
    # Map
    STAR \
      --genomeDir "${GENOMEDIR}"/star \
      --runThreadN 8 \
      --readFilesIn "${trim1}".gz "${trim2}".gz \
      --outSAMtype BAM SortedByCoordinate \
      --outBAMsortingThreadN 1 \
      --outFileNamePrefix "${bam_prefix}" \
      --readFilesCommand zcat  # append this option for .gz input
  
  else
    # Single-end data
    # Make sure fastq is zipped
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    # Map
    STAR \
      --genomeDir "${GENOMEDIR}"/star \
      --runThreadN 8 \
      --readFilesIn "${trim1}".gz \
      --outSAMtype BAM SortedByCoordinate \
      --outBAMsortingThreadN 1 \
      --outFileNamePrefix "${bam_prefix}" \
      --readFilesCommand zcat  # append this option for .gz input
  
  fi
fi