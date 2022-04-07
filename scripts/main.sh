#!/usr/bin/env bash


set -e
unset PYTHONPATH


# PARSE COMMAND LINE ARGUMENTS

while [[ $# -gt 0 ]]
do
  case "${1}" in
    -h|--help)
      echo ""
      echo "TrimMapCount"
      echo ""
      echo "Usage:"
      echo "  TrimMapCount/scripts/main.sh --option <argument>"
      echo ""
      echo "Options:"
      echo "  -h, --help                show this help message"
      echo ""
      echo "  -r, --rawdata-dir DIR     path to directory where raw fastq files are stored"
      echo "                            (no default)"
      echo ""
      echo "  -d, --data-dir DIR        path to directory for processed data files"
      echo "                            (default is same as raw data)"
      echo ""
      echo "  -g, --genome-dir DIR      path to directory containing genome files"
      echo "                            (default is /storage/fazal/genome/human/GRCh38.104)"
      echo ""
      echo "  -e, --env-dir DIR         path to directory with conda virtual environment"
      echo "                            (default is /storage/fazal/software/1_TrimMapCount/venv)"
      echo ""
      echo "  -t, --temp-dir DIR        path to directory for temporary files"
      echo "                            (default is /storage/fazal/tmp)"
      echo ""
      exit 0
      ;;
    -r|--rawdata-dir)
      RAWDATADIR="${2}"
      shift
      shift
      ;;
    -d|--data-dir)
      DATADIR="${2}"
      shift
      shift
      ;;
    -g|--genome-dir)
      GENOMEDIR="${2}"
      shift
      shift
      ;;
    -e|--env-dir)
      ENVDIR="${2}"
      shift
      shift
      ;;
    -t|--temp-dir)
      TEMPDIR="${2}"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option: ${1}"
      exit 1
      ;;
    *)
      echo "Unknown argument: ${1}"
      exit 1
      ;;
  esac
done


# SET UNSPECIFIED ARGUMENTS TO DEFAULTS

SCRIPTDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -z "${RAWDATADIR}" ]]
then
  echo "  Raw data directory not specified. Please supply path to raw data directory."
  exit 1
else
  echo "  Raw data directory set to ${RAWDATADIR}."
fi

if [[ -z "${DATADIR}" ]]
then
  DATADIR="${RAWDATADIR}"
  echo "  Processed data directory not specified. Defaulting to ${DATADIR}."
else
  echo "  Processed data directory set to ${DATADIR}."
fi

if [[ -z "${GENOMEDIR}" ]]
then
  GENOMEDIR=/storage/fazal/genome/human/GRCh38.104
  echo "  Genome directory not specified. Defaulting to ${GENOMEDIR}."
else
  echo "  Genome directory set to ${GENOMEDIR}."
fi

if [[ -z "${ENVDIR}" ]]
then
  ENVDIR=/storage/fazal/software/1_TrimMapCount/venv
  echo "  Environment directory not specified. Defaulting to ${ENVDIR}."
else
  echo "  Environment directory set to ${ENVDIR}."
fi
# Activate environment
export PATH="${ENVDIR}"/bin:"${PATH}"

if [[ -z "${TEMPDIR}" ]]
then
  TEMPDIR=/storage/fazal/tmp
  echo "  Temporary directory not specified. Defaulting to ${TEMPDIR}."
else
  echo "  Temporary directory set to ${TEMPDIR}."
fi
# Avoid dumping too much temporary data into system tmp directory
export TMPDIR="${TEMPDIR}"
export TEMP="${TEMPDIR}"
export TMP="${TEMPDIR}"


# CALL TRIMMAPCOUNT

while true
do
  read -p "Do you wish to start the TrimMapCount pipeline? [y/n] " yn
  case $yn in
    [Yy]*)
      sbatch "${SCRIPTDIR}"/TrimMapCount.sh "${SCRIPTDIR}" "${RAWDATADIR}" "${DATADIR}" "${GENOMEDIR}"
      break
      ;;
    [Nn]*)
      exit 0
      ;;
    *)
      echo "  Please answer yes or no."
      ;;
  esac
done

