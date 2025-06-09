process SNP2SEQZ {
	publishDir params.outdir_sequenza, mode: 'copy'

	input:
	path vcf
	path gc_wiggle

	output:
	path "vcf_out.seqz.gz", emit: vcf_seqz

	script:
	"""
	sequenza-utils snp2seqz -o vcf_out.seqz.gz -v ${vcf} -gc ${gc_wiggle}
	"""
}
