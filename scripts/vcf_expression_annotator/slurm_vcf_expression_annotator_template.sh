#!/bin/bash
#SBATCH --job-name="vcf-expression-annotator"
#SBATCH --cluster=<your-cluster-name>
#SBATCH --partition=<partition-name>
#SBATCH --qos=<qos-name>
#SBATCH --account=<your-account>
#SBATCH --cpus-per-task=16
#SBATCH --mem=258G
#SBATCH --time=3:00:00
#SBATCH --output=/path/to/project/vatools/slurm-%j.out
#SBATCH --error=/path/to/project/vatools/slurm-%j.err
#SBATCH --mail-user=your.email@institution.edu
#SBATCH --mail-type=ALL

# Java environment
export JAVA_HOME="/path/to/java/jdk-21.0.2"
export PATH="$JAVA_HOME/bin:$PATH"

# Nextflow environment variables
export TMPDIR=/path/to/tmp
export SINGULARITY_LOCALCACHEDIR=/path/to/tmp
export SINGULARITY_CACHEDIR=/path/to/tmp
export SINGULARITY_TMPDIR=/path/to/tmp
export NXF_SINGULARITY_CACHEDIR=/path/to/singularity_cache
export NXF_HOME=/path/to/tmp/.nextflow
export NXF_WORK=/scratch/work/vatools

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Python environment
export PATH="/path/to/venv/bin:$PATH"
source /path/to/venv/bin/activate

# Create tmp directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Source Nextflow setup script
source /path/to/setup_nextflow_env.sh

# Run vcf-expression-annotator
vcf-expression-annotator \
  /path/to/results/annotation/mutect2/SAMPLE_B_vs_SAMPLE_A/SAMPLE_B_vs_SAMPLE_A.mutect2.filtered_VEP.ann.vcf.gz \
  expression_SAMPLE_001_custom.tsv \
  custom \
  transcript \
  --id-column transcript_id \
  --expression-column SAMPLE_001 \
  -o SAMPLE_B_vs_SAMPLE_A.mutect2.filtered_VEP.ann.tx.vcf.gz \
  --ignore-ensembl-id-version \
  -s SAMPLE_001_SAMPLE_B
