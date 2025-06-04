process SEQZ_BINNING {
	publishDir params.outdir_sequenza, mode: 'copy'

	input:
	path seqz

	output:
	path 
