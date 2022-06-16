# Data Alignment for RNA-Seq Experiments

The TrimMapCount pipeline is designed to trim, map, and count your FASTQ reads with 
[icSHAPE](https://github.com/qczhang/icSHAPE), [STAR](https://github.com/alexdobin/STAR), 
and [HTSeq](https://github.com/htseq/htseq).


## Setup

If you are not a member of the Fazal Lab and don't have access to Baylor College 
of Medicine's MHGCP cluster, follow this link to 
[download and setup the pipeline](https://fazallabbcm.github.io/TrimMapCount/DownloadAndSetup) 
on your local computing environment.

### Naming raw data files

Rename your raw FASTQ files so that each file name has these 5 things (in order and separated 
by underscores):
   1. **Subcellular location** (can't contain an underscore)
      * Where APEX is targeted and/or which protein the enzyme is fused to (see the note below if you 
        are not using APEX-seq)
   2. **Experimental condition or "none"** (can't contain an underscore)
      * Could be a time limit, cell type, antibiotic treatment, etc.
   3. **"target" or "control"** (first letter can be capitalized)
      * Whether H<sub>2</sub>O<sub>2</sub> was added (target) or not (control)
   4. **A number to indicate which target or control sample** (one digit 0-9)
   5. **"R1.fastq" or "R2.fastq"** (or "R1.fastq.gz" and "R2.fastq.gz" for zipped files)

For example, single-end sequencing data (R1 only) from cytosol APEX cells (where the APEX2 enzyme 
is attached to the NES protein) that have been treated with puromycin might be named like this:
   ```
   Cytosol-NES_puromycin_target_1_R1.fastq
   Cytosol-NES_puromycin_target_2_R1.fastq
   Cytosol-NES_puromycin_control_1_R1.fastq
   Cytosol-NES_puromycin_control_2_R1.fastq
   ```

> **Note:**
> This pipeline isn't exclusive to APEX-seq experiments. For a generic RNA-Seq experiment, 
> replace the subcellular location with an additional experimental condition. For example, you 
> could name the file starting with the cell type instead: `HEK293_puromycin_target_1.R1.fastq`. 
> Need to label your data files with more than two experimental conditions? Just separate 
> the extra conditions with a hyphen or period like this: `HEK293-PloyA_puromycin.1min_target_1.R1.fastq`. 
> No matter what the experimental conditions are, there must be at least one target and one control 
> for every condition, and both targets and controls have to be named the same. In the last example, 
> the target could be treated with puromycin for 1 minute and the control not treated with puromycin. 
> Alternatively, the target could be polyadenylated RNA while the control is non polyadenylated RNA, 
> or the target could be HEK293 cells with HepG2 cells as the control. For our APEX-seq experiments, 
> "target" means we labeled RNA from that sample in a specific subcellular location by adding 
> H<sub>2</sub>O<sub>2</sub> to the cells, while "control" means unlabeled. Decide what "target" and 
> "control" mean for your experiment, and write it down.

### Sorting raw data files

To save lots of time, separate your FASTQ files into subfolders for each unique combination 
of subcellular location and experimental condition (like the picture below). This will allow 
you to run the TrimMapCount pipeline for each subfolder of raw data at the same time.

<img src="img/filestructure_example.png" width="60%" height="60%">


## Running the Pipeline

1. From the command line, add the TrimMapCount scripts folder to your PATH environment variable. 
   For Fazal Lab members, this can be done with the following code:
   ```
   export PATH=/storage/fazal/pipelines/TrimMapCount/scripts:"${PATH}"
   ```
   
2. Repeat steps 3 and 4 for each subfolder in your experiment's raw data folder.
   
3. Run the following code (replacing the file paths with the paths to your experiment's 
   raw data and processed data subfolders):
   ```
   TrimMapCount -r /path/to/rawdata -d /path/to/data
   ```

4. Make sure that the raw data and processed data file paths are correct. Then enter "y" to 
   start the pipeline.


## What next?

You can check the log file in your processed data folder to see the progress of your job as it runs.

If you encounter any errors, see our 
[troubleshooting](https://fazallabbcm.github.io/TrimMapCount/Troubleshooting) page for help.

Once [TrimMapCount](https://fazallabbcm.github.io/TrimMapCount) has finished, you will have all of 
the data files necessary for the [ProcessCounts](https://fazallabbcm.github.io/ProcessCounts) and 
[BamToBigWig](https://fazallabbcm.github.io/BamToBigWig) pipelines.
