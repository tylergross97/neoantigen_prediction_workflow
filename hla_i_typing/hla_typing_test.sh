#!/bin/bash
#SBATCH --job-name="hla_typing_test"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16           
#SBATCH --mem=512G                   
#SBATCH --time=8:00:00             
#SBATCH --output=slurm-%j.out        
#SBATCH --error=slurm-%j.err         
#SBATCH --mail-user=tgross2@buffalo.edu
#SBATCH --mail-type=ALL

# Set up environment
export TMPDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_LOCALCACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_TMPDIR=/projects/academic/rpili/tgross2/tmp
export NXF_SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/singularity_cache

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Create directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Source setup script
source /projects/academic/rpili/tgross2/setup_nextflow_env.sh

# Navigate to project directory
cd /projects/academic/rpili/Jonathan_Lovell_project/hla_i_typing

# Run with permanent config file
nextflow run nf-core/hlatyping \
    -r 2.1.0 \
    -profile test,singularity \
    --outdir test_results \
    -c /projects/academic/rpili/tgross2/hlatyping_fix.config \
    -resume
