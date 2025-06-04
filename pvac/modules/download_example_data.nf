process DOWNLOAD_EXAMPLE_DATA {
	container "'griffithlab/pvactools:latest'"
	publishDir params.outdir_example_data, mode: 'symlink'

	output:
	path "${params.outdir_example_data}", emit: example_data

	script:
	"""
	pvacseq download_example_data ${params.outdir_example_data}
	"""
}
