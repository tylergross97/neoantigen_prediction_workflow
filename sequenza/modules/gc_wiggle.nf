process GC_WIGGLE {
	publishDir params.outdir_references, mode: 'copy'

	input:
	path fasta

	output:
	path "reference.gc50Base.wig.gz", emit: gc_wiggle_track

	script:
	"""
	gunzip -c ${fasta} > reference.fa
	sequenza-utils gc_wiggle -w 50 --fasta reference.fa -o reference.gc50Base.wig.gz
	"""
}
