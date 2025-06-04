#!/bin/bash
#SBATCH --job-name="epitope_prediction"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=24
#SBATCH --mem=258G
#SBATCH --time=36:00:00
#SBATCH --output=/projects/academic/rpili/Jonathan_Lovell_project/epitope_prediction/slurm-%j.out
#SBATCH --error=/projects/academic/rpili/Jonathan_Lovell_project/epitope_prediction/slurm-%j.err
#SBATCH --mail-user=tgross2@buffalo.edu
#SBATCH --mail-type=ALL

# Set up Java environment (locally installed)
export JAVA_HOME="/projects/academic/rpili/tgross2/java/jdk-21.0.2"
export PATH="$JAVA_HOME/bin:$PATH"
# Set up Nextflow environment variables
export TMPDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_LOCALCACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_TMPDIR=/projects/academic/rpili/tgross2/tmp
export NXF_SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/singularity_cache
export NXF_HOME=/projects/academic/rpili/tgross2/tmp/.nextflow
export NXF_WORK=/vscratch/grp-rpili/neoantigen/epitope
# Set container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp
# Create and set permissions for directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
# Source your setup script
source /projects/academic/rpili/tgross2/setup_nextflow_env.sh
# Verify environment
echo "=== Environment Check ==="
echo "Java version: $(java -version 2>&1 | head -1)"
echo "Nextflow version: $(nextflow -version 2>&1 | grep version)"
echo "=========================="

# Run nf-core/sarek
nextflow run nf-core/epitopeprediction -r 3.0.0 \
    -profile singularity \
    --input /projects/academic/rpili/Jonathan_Lovell_project/epitope_prediction/samplesheet_esophagus.csv \
    --outdir /projects/academic/rpili/Jonathan_Lovell_project/epitope_prediction/esophagus_results \
    --genome_reference grch37 \
    --tools mhcflurry \
    --fasta_output \
    -work-dir /vscratch/grp-rpili/neoantigen_prediction/sarek \
    -resume
