#!/bin/bash
#SBATCH --job-name="PV1_rnaseq"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16           
#SBATCH --mem=258G                   
#SBATCH --time=36:00:00             
#SBATCH --output=slurm-%j.out        
#SBATCH --error=slurm-%j.err         
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
export NXF_WORK=/vscratch/grp-rpili/neoantigen/PV1_rna

# Set container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Source your setup script
source /projects/academic/rpili/tgross2/setup_nextflow_env.sh

# Verify environment
echo "=== Environment Check ==="
echo "Java version: $(java -version 2>&1 | head -1)"
echo "Nextflow version: $(nextflow -version 2>&1 | grep version)"
echo "=========================="

# Run the pipeline with latest Ensembl references
nextflow run nf-core/rnaseq -r dev \
    --input /projects/academic/rpili/Jonathan_Lovell_project/data/sample_sheets/PV1_rnaseq.csv \
    --aligner star_salmon \
    --fasta /projects/academic/rpili/references/ensembl_112/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
    --gtf /projects/academic/rpili/references/ensembl_112/Homo_sapiens.GRCh38.112.gtf.gz \
    --save_reference \
    --max_cpus 16 \
    --max_memory '258.GB' \
    --max_time '36.h' \
    --outdir /projects/academic/rpili/Jonathan_Lovell_project/results/PV1/PV1_rnaseq \
    -profile singularity \
    -work-dir /vscratch/grp-rpili/neoantigen/PV1_rna \
    --email tgross2@buffalo.edu \
    -resume
