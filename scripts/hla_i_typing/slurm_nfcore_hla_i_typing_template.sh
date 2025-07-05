#!/bin/bash
#SBATCH --job-name="hla_typing_pipeline"
#SBATCH --cluster=<your-cluster-name>
#SBATCH --partition=<partition-name>
#SBATCH --qos=<qos-name>
#SBATCH --account=<your-account>
#SBATCH --cpus-per-task=16
#SBATCH --mem=512G
#SBATCH --time=24:00:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --mail-user=your.email@institution.edu
#SBATCH --mail-type=ALL

# Set up environment
export TMPDIR=/path/to/tmp
export SINGULARITY_LOCALCACHEDIR=/path/to/tmp
export SINGULARITY_CACHEDIR=/path/to/tmp
export SINGULARITY_TMPDIR=/path/to/tmp
export NXF_SINGULARITY_CACHEDIR=/path/to/singularity_cache

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Create directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Create and set permissions for work directory
mkdir -p /scratch/work/hla_typing
chmod 755 /scratch/work/hla_typing

# Source setup script
source /path/to/setup_nextflow_env.sh

# Navigate to project directory
cd /path/to/project/hla_i_typing

# Run HLA typing with specified work directory
nextflow run nf-core/hlatyping \
    -r 2.1.0 \
    --input /path/to/fastq/hla_typing_samplesheet.csv \
    --outdir hla_typing_results \
    -profile singularity \
    -c /path/to/config/hlatyping_production.config \
    -work-dir /scratch/work/hla_typing \
    --email your.email@institution.edu \
    -resume
