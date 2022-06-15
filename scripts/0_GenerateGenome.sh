
GENOMEDIR="${1}"
fa="${2}"
gtf="${3}"

if [[ ! -d "${GENOMEDIR}" ]]
then
  echo "Genome directory not found."
  exit 1
fi

if [[ ! -d "${GENOMEDIR}"/star ]]
then
  mkdir "${GENOMEDIR}"/star
fi

if [[ -s "${GENOMEDIR}"/star/SAindex ]]
then
  echo "Generate genome already complete; skipping re-generation."
  # Make sure gtf is unzipped
  [ -f "${gtf}" ] || gunzip "${gtf}.gz"
else
  echo "Generating genome. Estimated time for genome generation is 90 minutes."
  # Make sure fasta and gtf are unzipped
  [ -f "${fa}" ] || gunzip "${fa}".gz
  [ -f "${gtf}" ] || gunzip "${gtf}".gz
  # Generate genome index
  STAR \
    --runThreadN 8 \
    --runMode genomeGenerate \
    --genomeDir "${GENOMEDIR}"/star \
    --genomeFastaFiles "${fa}" \
    --sjdbGTFfile "${gtf}"
  # Zip fasta file
  gzip "${fa}"
fi
