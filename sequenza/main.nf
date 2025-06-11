#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { PRINT_VERSIONS } from './modules/print_versions.nf'
include { GC_WIGGLE } from './modules/gc_wiggle.nf'
include { FASTP } from './modules/fastp.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { INDEX_HUMAN } from './modules/index_human.nf'
include { BWAMEM2_ALIGN } from './modules/bwamem2_align.nf'
include { INDEX_BAM } from './modules/index_bam.nf'
include { SORT_BAM } from './modules/sort_bam.nf'
include { BAM2SEQZ } from './modules/bam2seqz.nf'

workflow {
	Channel
    		.fromPath(params.fasta)
    		.set { fasta_ch }

	// Create file pairs
	reads_ch = Channel
        	.fromFilePairs("${params.reads_dir}/*_{1,2}.fastq.gz", checkIfExists: true)
        	.filter { key, _files -> key in params.sample_ids }

	PRINT_VERSIONS()
	GC_WIGGLE(params.fasta)
	human_index = INDEX_HUMAN(params.fasta)
	FASTP(reads_ch)
	BWAMEM2_ALIGN(FASTP.out.trimmed_reads, human_index)
	//tumor_bam_ch = BWAMEM2_ALIGN.out.bam.filter { sample_id, _unused -> sample_id == params.tumor_id }.map { _unused, bam -> bam }
	//normal_bam_ch = BWAMEM2_ALIGN.out.bam.filter { sample_id, _unused -> sample_id == params.normal_id }.map { _unused, bam -> bam }
	SORT_BAM(BWAMEM2_ALIGN.out).view()
	INDEX_BAM(SORT_BAM.out).view()
	// tumor_bam_idx_ch = INDEX_BAM.out.indexed_bam.filter { sample_id, _unused -> sample_id == params.tumor_id }.map { _unused, indexed_bam -> indexed_bam }
        // normal_bam_idx_ch = INDEX_BAM.out.indexed_bam.filter { sample_id, _unused -> sample_id == params.normal_id }.map { _unused, indexed_bam -> indexed_bam }
	/* bam2seqz_input_ch = tumor_bam_ch
    		.combine(normal_bam_ch)
    		.map { it.flatten() }
    		.combine(tumor_bam_idx_ch)
    		.map { it.flatten() }
    		.combine(normal_bam_idx_ch)
    		.map { it.flatten() }
    		.combine(GC_WIGGLE.out)
    		.map { it.flatten() }
    		.combine(fasta_ch)
    		.map { it.flatten() }
    		.map { flat ->
        		def (t_bam, n_bam, t_bai, n_bai, gc, fasta) = flat
        		tuple(t_bam, n_bam, t_bai, n_bai, gc, fasta)
    	} */
	// BAM2SEQZ(bam2seqz_input_ch)
}
