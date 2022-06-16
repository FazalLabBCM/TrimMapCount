# Download and Setup

This page is for users who do not have access to the MHGCP cluster at Baylor College of Medicine.
These instructions will help you download the necessary files and set up your computing environment 
in preparation for using the TrimMapCount pipeline.


### 1. Create virtual environment

[Install Conda or Miniconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html), 
make a folder for virtual environments, and add a folder inside called "DataAlignment". Then use the code 
below to create a virtual environment for the TrimMapCount pipeline: 

```
conda create \
  -p /path/to/environments/DataAlignment/venv \
  star=2.7.10a \
  htseq=0.11.3 \
  python=3.7.13 \
  fastqc=0.11.9 \
  -c bioconda
```


### 2. Download pipeline repository

Visit https://github.com/FazalLabBCM/TrimMapCount, and use the green ‘Code’ button to download the repository. 


### 3. Configure pipeline defaults

Edit the CONFIG file in the repository folder to include the absolute paths to your folders:

* GENOMEDIR is the folder containing your genome FASTA and GTF files. Download these two files if you have not 
  already. (We use genome assembly GRCh38.p13 from [Ensembl release 104](http://ftp.ensembl.org/pub/release-104/).)
  
* ENVDIR is the virtual environment that you made in the first step: `path/to/environments/DataAlignment/venv`.
  
* TEMPDIR is a folder for temporary files.
