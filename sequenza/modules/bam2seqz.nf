process BAM2SEQZ {
	publishDir params.outdir_sequenza, mode: 'copy'
	
	input:
	tuple path(tumor_bam), path(normal_bam), path(tumor_bam_idx), path(normal_bam_idx), path(gc_wiggle), path(fasta)

	output:
	path "out.seqz.gz", emit: seqz

	script:
	"""
	sequenza-utils bam2seqz -n ${normal_bam} -t ${tumor_bam} --fasta ${fasta} -gc ${gc_wiggle} -o out.seqz.gz
	"""
}
