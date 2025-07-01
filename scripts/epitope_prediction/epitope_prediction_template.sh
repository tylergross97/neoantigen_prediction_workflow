#!/bin/bash
#SBATCH --job-name="epitope_prediction"
#SBATCH --cluster=<your-cluster-name>
#SBATCH --partition=<partition-name>
#SBATCH --qos=<qos-name>
#SBATCH --account=<your-account>
#SBATCH --cpus-per-task=24
#SBATCH --mem=258G
#SBATCH --time=36:00:00
#SBATCH --output=/path/to/project/epitope_prediction/slurm-%j.out
#SBATCH --error=/path/to/project/epitope_prediction/slurm-%j.err
#SBATCH --mail-user=your.email@institution.edu
#SBATCH --mail-type=ALL

# Set up Java environment
export JAVA_HOME="/path/to/java/jdk-21.0.2"
export PATH="$JAVA_HOME/bin:$PATH"

# Set up Nextflow environment variables
export TMPDIR=/path/to/tmp
export SINGULARITY_LOCALCACHEDIR=/path/to/tmp
export SINGULARITY_CACHEDIR=/path/to/tmp
export SINGULARITY_TMPDIR=/path/to/tmp
export NXF_SINGULARITY_CACHEDIR=/path/to/singularity_cache
export NXF_HOME=/path/to/tmp/.nextflow
export NXF_WORK=/scratch/work/epitope_prediction

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Create and set permissions for directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Source your setup script
source /path/to/setup_nextflow_env.sh

# Verify environment
echo "=== Environment Check ==="
echo "Java version: $(java -version 2>&1 | head -1)"
echo "Nextflow version: $(nextflow -version 2>&1 | grep version)"
echo "=========================="

# Run nf-core/epitopeprediction
nextflow run nf-core/epitopeprediction -r 3.0.0 \
    -profile singularity \
    --input /path/to/epitope_prediction/samplesheet.csv \
    --outdir /path/to/epitope_prediction/results \
    --genome_reference grch37 \
    --tools mhcflurry \
    --fasta_output \
    -work-dir /scratch/work/epitope_prediction \
    -resume
