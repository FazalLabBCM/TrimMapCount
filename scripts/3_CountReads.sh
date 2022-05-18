
gtf="${1}"
base="${2}"
bam="${3}"
counts="${4}"

if [[ -s "${counts}" ]]
then
  echo "Count reads in ${base} already complete; skipping re-counting."
else
  echo "Counting reads in ${base}. Estimated time for counting is 30-90 minutes."
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
    --idattr=gene_id "${bam}" "${gtf}" > "${counts}"
  # Zip bam
  echo "Zipping bam file..."
  [ -f "${bam}.gz" ] || gzip "${bam}"
fi
