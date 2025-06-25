#!/bin/bash
#SBATCH --job-name="PV1_hlatyping"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16           
#SBATCH --mem=512G                   
#SBATCH --time=24:00:00             
#SBATCH --output=PV1_hlatyping-%j.out        
#SBATCH --error=PV1_hlatyping-%j.err         
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

# Create and set permissions for work directory
mkdir -p /vscratch/grp-rpili/neoantigen/PV1_hlatyping
chmod 755 /vscratch/grp-rpili/neoantigen/PV1_hlatyping

# Source setup script
source /projects/academic/rpili/tgross2/setup_nextflow_env.sh

# Navigate to project directory
cd /projects/academic/rpili/Jonathan_Lovell_project/hla_i_typing

# Run HLA typing with specified work directory
nextflow run nf-core/hlatyping \
    -r 2.1.0 \
    --input /projects/academic/rpili/Jonathan_Lovell_project/data/sample_sheets/PV1_hlatyping.csv \
    --outdir /projects/academic/rpili/Jonathan_Lovell_project/results/PV1/PV1_hlatyping \
    -profile singularity \
    -c /projects/academic/rpili/tgross2/hlatyping_production.config \
    -work-dir /vscratch/grp-rpili/neoantigen/PV1_hlatyping \
    --email tgross2@buffalo.edu \
    -resume
