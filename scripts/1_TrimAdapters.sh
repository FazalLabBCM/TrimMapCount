
SCRIPTDIR="${1}"
DATADIR="${2}"
base="${3}"
fq1="${4}"
fq2="${5}"
trim1="${6}"
trim2="${7}"
ADAPTER_FILE="${8}"

if [[ -f "${DATADIR}"/"${base}"R1_trim.fastq.trimlog ]]
then
  echo "Trim adapters in ${base} already complete; skipping re-trimming."
else
  echo "Trimming adapters in ${base}. Estimated time for trimming is 15-30 minutes."

  if [[ -f "${fq2}" ]] || [[ -f "${fq2}".gz ]]
  then
    # Paired-end data
    # Unzip fastqs
    echo "Unzipping fastq files..."
    [ -f "${fq1}" ] || gunzip "${fq1}".gz
    [ -f "${fq2}" ] || gunzip "${fq2}".gz
    # Create FastQC Reports
    echo "Creating FastQC reports..."
    fastqc --quiet --outdir "${DATADIR}" "${fq1}" "${fq2}"
    # Trim
    perl "${SCRIPTDIR}"/icSHAPE/scripts/trimming.pl \
      -1 "${fq1}" \
      -2 "${fq2}" \
      -p "${trim1}" \
      -q "${trim2}" \
      -a "${ADAPTER_FILE}" \
      -l 0 \
      -t 0 \
      -m 36
    # Zip fastqs
    echo "Zipping fastq files..."
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    [ -f "${trim2}.gz" ] || gzip "${trim2}"
    [ -f "${fq1}.gz" ] || gzip "${fq1}"
    [ -f "${fq2}.gz" ] || gzip "${fq2}"
  
  else
    # Single-end data
    # Unzip fastq
    echo "Unzipping fastq file..."
    [ -f "${fq1}" ] || gunzip "${fq1}".gz
    # Create FastQC Report
    echo "Creating FastQC report..."
    fastqc --quiet --outdir "${DATADIR}" "${fq1}"
    # Trim
    perl "${SCRIPTDIR}"/icSHAPE/scripts/trimming.pl \
      -U "${fq1}" \
      -o "${trim1}" \
      -a "${ADAPTER_FILE}" \
      -l 0 \
      -t 0 \
      -m 36
    # Zip fastqs
    echo "Zipping fastq files..."
    [ -f "${trim1}.gz" ] || gzip "${trim1}"
    [ -f "${fq1}.gz" ] || gzip "${fq1}"
  
  fi
fi
