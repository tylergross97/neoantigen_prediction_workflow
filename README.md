# Neoantigen Prediction

This repository is a working draft of a set of analyses to identify candidate neoantigens for personalized cancer vaccines from tumor-normal WES + RNA-seq data.

## Key Attributes for Neoantigen Prioritization

To effectively identify and prioritize candidate neoantigens for personalized cancer vaccines (PCVs), several biological and computational criteria are considered:

- **Somatic variants:**  
  The peptide must be unique to the tumor (not germline). T cells undergo negative selection in the thymus if they recognize and bind too strongly to neoepitopes expressed on normal cells. To identify somatic mutations, tumor and normal WES data are processed with the `nf-core/sarek` pipeline, generating a VEP-annotated VCF file. This involves SNV/Indel calling (Mutect2, Strelka) and somatic copy number analysis (CNVkit). For now, only the Mutect2-annotated VCF is used for downstream analysis.

- **Variant expression:**  
  The variant must be expressed in the tumor to be presented on the HLA-I receptor. Tumor RNA-seq data is quantified using `nf-core/rnaseq` (STAR-Salmon). The `vcf-expression-annotator` from vatools annotates the VCF with transcript-level expression. Previous studies have used TPM cutoffs (e.g., 0.01) to filter candidates. The annotated VCF is converted to CSV using `/scripts/vcf_expression_annotator/vcf_to_csv.py`.

- **Binding affinity:**  
  The patient's HLA-I alleles must have adequate predicted binding affinity with the neopeptide. HLA-I typing is performed with `nf-core/hlatyping` (OptiType). The HLA-I results and the annotated VCF (optionally cleaned with `/scripts/epitope_prediction/clean_vep_ann_vcf.py`) are input to `nf-core/epitopeprediction`, which predicts HLA-I/peptide binding affinity using mhcflurry. The key output is `mhcflurry_affinity_percentile`, with strong binders defined as rank < 0.5.

- **Clonality:**  
  **Under development.** We aim to estimate the fraction of cancer cells exhibiting each variant and peptide, as tumors are often heterogeneous. Clonal driver mutations should have a cancer cell fraction of 100%. PureCN can estimate the clonality of each variant.

---

## Workflow Overview

```mermaid
flowchart TD
    %% Inputs
    wes_fastq([WES Tumor/Normal FASTQ])
    rnaseq_fastq([Tumor/Normal RNA-seq FASTQ])

    %% Processes/Tools
    sarek{{nf-core/sarek (Mutect2/VEP)}}
    rnaseq{{nf-core/rnaseq (STAR-Salmon)}}
    expr_annotator{{vcf-expression-annotator (vatools)}}
    vcf2csv{{vcf_to_csv.py}}
    epipred{{epitope_prediction (mhcflurry)}}
    downstream{{neoantigen_downstream.py}}

    %% Files/Artifacts
    vep_vcf([VEP-annotated VCF])
    expr_vcf([VEP-annotated VCF with Variant Expression])
    expr_csv([Variant Expression CSV])
    epi_tsv([Epitope Prediction TSV])
    final([Final CSVs & Plots])

    %% Workflow
    wes_fastq --> sarek
    sarek --> vep_vcf
    vep_vcf --> expr_annotator
    rnaseq_fastq --> rnaseq
    rnaseq --> expr_annotator
    expr_annotator --> expr_vcf
    expr_vcf --> vcf2csv
    vcf2csv --> expr_csv
    expr_csv --> downstream
    vep_vcf --> epipred
    expr_vcf --> epipred
    epipred --> epi_tsv
    epi_tsv --> downstream
    downstream --> final
```

### Step-by-step Explanation

1. **Somatic Variant Calling:**
   - **Input:** Tumor and normal WES FASTQ files
   - **Tool:** `nf-core/sarek` pipeline (Mutect2/Strelka)
   - **Output:** VEP-annotated VCF file containing somatic variants

2. **Expression Annotation:**
   - **Input:** VEP-annotated VCF
   - **Tool:** `vcf-expression-annotator` from vatools
   - **Output:** VCF annotated with transcript expression (from RNA-seq)

3. **VCF to CSV Conversion:**
   - **Input:** Expression-annotated VCF
   - **Tool:** `scripts/vcf_expression_annotator/vcf_to_csv.py`
   - **Output:** CSV summarizing variants and their expression

4. **RNA-seq Quantification:**
   - **Input:** Tumor RNA-seq FASTQ
   - **Tool:** `nf-core/rnaseq` (STAR-Salmon)
   - **Output:** Transcript-level expression quantification (used in annotation)

5. **Epitope Prediction:**
   - **Input:** Cleaned VCF and HLA typing results
   - **Tool:** `epitope_prediction` (mhcflurry)
   - **Output:** TSV with predicted HLA-I/peptide binding affinities

6. **Downstream Analysis:**
   - **Input:** Expression CSV and epitope prediction TSV
   - **Tool:** `scripts/downstream/neoantigen_downstream.py`
   - **Output:** Final merged CSVs and plots for candidate neoantigen prioritization

---
