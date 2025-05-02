#!/bin/bash
#SBATCH --job-name="fetchngs"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16           # Request 16 CPU cores per task based on nextflow.config
#SBATCH --mem=126G                   # Request 512 GB of memory based on nextflow.config
#SBATCH --time=1:00:00             
#SBATCH --output=slurm-%j.out        # Standard output file (%j will be replaced by the job ID)
#SBATCH --error=slurm-%j.err         # Standard error file
#SBATCH --mail-user=tgross2@buffalo.edu
#SBATCH --mail-type=ALL

module load nextflow/23.10.0

# Run the pipeline
nextflow run nf-core/fetchngs -profile singularity \
    --input ids.csv \
    --outdir fastq \
    --download_method sratools


