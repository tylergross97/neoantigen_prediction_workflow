#!/bin/bash
#SBATCH --job-name="sequenza"
#SBATCH --cluster=ub-hpc
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=rpili
#SBATCH --cpus-per-task=16
#SBATCH --mem=258G
#SBATCH --time=3:00:00
#SBATCH --output=/projects/academic/rpili/Jonathan_Lovell_project/vatools/slurm-%j.out
#SBATCH --error=/projects/academic/rpili/Jonathan_Lovell_project/vatools/slurm-%j.err
#SBATCH --mail-user=tgross2@buffalo.edu
#SBATCH --mail-type=ALL

# Java environment (locally installed)
export JAVA_HOME="/projects/academic/rpili/tgross2/java/jdk-21.0.2"
export PATH="$JAVA_HOME/bin:$PATH"

# Nextflow environment variables
export TMPDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_LOCALCACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/tmp
export SINGULARITY_TMPDIR=/projects/academic/rpili/tgross2/tmp
export NXF_SINGULARITY_CACHEDIR=/projects/academic/rpili/tgross2/singularity_cache
export NXF_HOME=/projects/academic/rpili/tgross2/tmp/.nextflow
export NXF_WORK=/vscratch/grp-rpili/neoantigen/vatools

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Add your Python virtualenv's bin directory to PATH so tools like samtools, tabix, etc. are available
export PATH="/projects/academic/rpili/tyler_venv/bin:$PATH"

# Optional: activate the Python virtual environment for Python packages, env vars, and LD_LIBRARY_PATH
source /projects/academic/rpili/tyler_venv/bin/activate

# Create and set permissions for tmp directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Source your Nextflow setup script if needed
source /projects/academic/rpili/tgross2/setup_nextflow_env.sh

vep-annotation-reporter /projects/academic/rpili/Jonathan_Lovell_project/somatic_variant_calling_test/results/annotation/mutect2/SRX19052222_SRR23100029_vs_SRX19052221_SRR23100030/SRX19052222_SRR23100029_vs_SRX19052221_SRR23100030.mutect2.filtered_VEP.ann.vcf.gz Allele Consequence IMPACT SYMBOL Gene Feature_type Feature BIOTYPE EXON INTRON HGVSc HGVSp cDNA_position CDS_position Protein_position Amino_acids Codons Existing_variation DISTANCE STRAND FLAGS VARIANT_CLASS SYMBOL_SOURCE HGNC_ID CANONICAL MANE MANE_SELECT MANE_PLUS_CLINICAL TSL APPRIS CCDS ENSP SWISSPROT TREMBL UNIPARC UNIPROT_ISOFORM GENE_PHENO SIFT PolyPhen DOMAINS miRNA AF AFR_AF AMR_AF EAS_AF EUR_AF SAS_AF gnomADe_AF gnomADe_AFR_AF gnomADe_AMR_AF gnomADe_ASJ_AF gnomADe_EAS_AF gnomADe_FIN_AF gnomADe_MID_AF gnomADe_NFE_AF gnomADe_REMAINING_AF gnomADe_SAS_AF gnomADg_AF gnomADg_AFR_AF gnomADg_AMI_AF gnomADg_AMR_AF gnomADg_ASJ_AF gnomADg_EAS_AF gnomADg_FIN_AF gnomADg_MID_AF gnomADg_NFE_AF gnomADg_REMAINING_AF gnomADg_SAS_AF MAX_AF MAX_AF_POPS FREQS CLIN_SIG SOMATIC PHENO PUBMED MOTIF_NAME MOTIF_POS HIGH_INF_POS MOTIF_SCORE_CHANGE TRANSCRIPTION_FACTORS -o vep-annotation-report.tsv

