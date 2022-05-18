
GENOMEDIR="${1}"
fa="${2}"
gtf="${3}"

if [[ -d "${GENOMEDIR}"/star ]]
then
  if [[ "$(ls -A ${GENOMEDIR}/star)" ]]
  then
    echo "Generate genome already complete; skipping re-generation."
    # Make sure gtf is unzipped
    [ -f "${gtf}" ] || gunzip "${gtf}.gz"
  else
    echo "Generating genome. Estimate time for genome generation is 90 minutes."
    # Make sure fasta and gtf are unzipped
    [ -f "${fa}" ] || gunzip "${fa}".gz
    [ -f "${gtf}" ] || gunzip "${gtf}".gz
    # Generate genome index
    STAR \
      --runThreadN 8 \
      --runMode genomeGenerate \
      --genomeDir "${GENOMEDIR}"/star \
      --genomeFastaFiles "${fa}" \
      --sjdbGTFfile "${gtf}" \
      --limitGenomeGenerateRAM 120000000000 \
      --limitSjdbInsertNsj 4000000
    # Zip fasta file
    gzip "${fa}"
  fi
else
  echo "Genome directory not found."
  exit 1
fi
