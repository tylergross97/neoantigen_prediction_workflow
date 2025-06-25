process CNS_TO_SEG {
	container "community.wave.seqera.io/library/cnvkit:0.9.12--0f8b2dcdee7508b0"
	publishDir params.outdir_references, mode: 'copy'

	input:
	tuple val(sample_id), path(cns_file)

	output:
	path "${sample_id}.seg", emit: seg

	script:
	"""
	cnvkit.py export seg ${cns_file} --enumerate-chroms -o ${sample_id}.seg
	"""
}
