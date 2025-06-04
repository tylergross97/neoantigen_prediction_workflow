#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { PRINT_VERSIONS } from './modules/print_versions.nf'
include { GC_WIGGLE } from './modules/gc_wiggle.nf'
include { FASTP } from './modules/fastp.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { INDEX_HUMAN } from './modules/index_human.nf'
include { BWAMEM2_ALIGN } from './modules/bwamem2_align.nf'
include { SORT_BAM } from './modules/sort_bam.nf'

Channel
    .fromPath(params.fasta)
    .map { fasta ->
        def id = fasta.getBaseName().replaceFirst(/\.(fasta|fa|fna)$/, '')
        tuple([ id: id ], fasta)
    }
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
	SORT_BAM(BWAMEM2_ALIGN.out.bam)
}
