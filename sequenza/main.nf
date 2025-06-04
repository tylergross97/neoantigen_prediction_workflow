#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { PRINT_VERSIONS } from './modules/print_versions.nf'
include { GC_WIGGLE } from './modules/gc_wiggle.nf'
include { FASTP } from './modules/fastp.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { INDEX_HUMAN } from './modules/index_human.nf'
include { BWAMEM2_ALIGN } from './modules/bwamem2_align.nf'
include { BAM2SEQZ } from './modules/bam2seqz.nf'

Channel
    .fromPath(params.fasta)
    .set { fasta_ch }

// Create file pairs
reads_ch = Channel
	.fromFilePairs("${params.reads_dir}/*_{1,2}.fastq.gz", checkIfExists: true)
	.filter { key, files -> key in params.sample_ids }

workflow {
	PRINT_VERSIONS()
	GC_WIGGLE(params.fasta)
	human_index = INDEX_HUMAN(params.fasta)
	FASTP(reads_ch)
	BWAMEM2_ALIGN(FASTP.out.trimmed_reads, human_index)
	tumor_bam_ch = BWAMEM2_ALIGN.out.bam.filter { sample_id, _ -> sample_id == params.tumor_id }.map { _, bam -> bam }
	normal_bam_ch = BWAMEM2_ALIGN.out.bam.filter { sample_id, _ -> sample_id == params.normal_id }.map { _, bam -> bam }
	BAM2SEQZ(tumor_bam_ch, normal_bam_ch, GC_WIGGLE.out, fasta_ch)
}
