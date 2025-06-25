#!/bin/bash
#SBATCH --job-name="rna_seq_pipeline_test"
#SBATCH --cluster=<your-cluster-name>
#SBATCH --partition=<partition-name>
#SBATCH --qos=<qos-name>
#SBATCH --account=<your-account>
#SBATCH --cpus-per-task=16
#SBATCH --mem=258G
#SBATCH --time=36:00:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
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
export NXF_WORK=/path/to/tmp/nextflow_work

# Set container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Source setup script
source /path/to/setup_nextflow_env.sh

# Verify environment
echo "=== Environment Check ==="
echo "Java version: $(java -version 2>&1 | head -1)"
echo "Nextflow version: $(nextflow -version 2>&1 | grep version)"
echo "=========================="

# Run nf-core/rnaseq pipeline
nextflow run nf-core/rnaseq -r dev \
    --input /path/to/fastq/sample_sheet.csv \
    --aligner star_salmon \
    --fasta /path/to/references/ensembl/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
    --gtf /path/to/references/ensembl/Homo_sapiens.GRCh38.gtf.gz \
    --save_reference \
    --max_cpus 16 \
    --max_memory '258.GB' \
    --max_time '36.h' \
    --outdir /path/to/output/results_rna_seq \
    -profile singularity \
    -work-dir /path/to/tmp/nextflow_work \
    --email your.email@institution.edu \
    -resume
