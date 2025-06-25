#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

Channel
    .fromPath(params.cns_file)
    .map { file -> tuple(file.getBaseName().replaceFirst(/\.cns$/, ''), file) }
    .set { ch_cns }

include { CNS_TO_SEG } from './modules/cns_to_seg.nf'
include { PURECN } from './modules/purecn/purecn.nf'

workflow {
	CNS_TO_SEG(ch_cns)
	PURECN(CNS_TO_SEG.out.seg, params.snp_blacklist, params.tumor_cnr, params.vcf)	
}
