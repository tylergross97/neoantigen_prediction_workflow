process GC_WIGGLE {
	publishDir params.outdir_references, mode: 'copy'

	input:
	path fasta

	output:
	path "${fasta}.gc50Base.wig.gz", emit: gc_wiggle_track

	script:
	"""
	sequenza-utils gc_wiggle -w 50 --fasta ${fasta} -o ${fasta}.gc50Base.wig.gz
	"""
}
