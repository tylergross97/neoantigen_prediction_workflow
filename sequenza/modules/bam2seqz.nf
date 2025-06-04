process BAM2SEQZ {
	publishDir params.outdir_sequenza, mode: 'copy'
	
	input:
	path tumor_bam
	path normal_bam
	path gc_wiggle
	path fasta

	output:
	path "out.seqz.gz", emit: seqz

	script:
	"""
	sequenza-utils bam2seqz -n ${normal_bam} -t ${tumor_bam} --fasta ${fasta} -gc ${gc_wiggle} -o out.seqz.gz
	"""
}
