#!/bin/bash
#SBATCH --job-name="fetchngs"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16           # Request 16 CPU cores per task based on nextflow.config
#SBATCH --mem=126G                   # Request 512 GB of memory based on nextflow.config
#SBATCH --time=6:00:00             
#SBATCH --output=slurm-%j.out        # Standard output file (%j will be replaced by the job ID)
#SBATCH --error=slurm-%j.err         # Standard error file
#SBATCH --mail-user=tgross2@buffalo.edu
#SBATCH --mail-type=ALL

export SINGULARITY_LOCALCACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_TMPDIR=/projects/academic/rpili/tgross2/tmp
export NXF_SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/singularity_cache

module load nextflow/23.10.0

nextflow run nf-core/sarek -profile singularity \
    --input samplesheet.csv \
    --outdir results \
    --wes \
    --genome GRCh38 \
    --tools strelka,mutect2,manta,vep \
    --igenomes_base s3://ngi-igenomes/igenomes/
