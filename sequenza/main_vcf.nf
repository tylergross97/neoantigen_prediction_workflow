#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { PRINT_VERSIONS } from './modules/print_versions.nf'
include { GC_WIGGLE } from './modules/gc_wiggle.nf'
include { SNP2SEQZ } from './modules/snp2seqz'

Channel
    .fromPath(params.fasta)
    .set { fasta_ch }

Channel
    .fromPath(params.vcf)
    .set { vcf_ch }

workflow {
	PRINT_VERSIONS()
	GC_WIGGLE(params.fasta)
	SNP2SEQZ(vcf_ch, GC_WIGGLE.out)
}
