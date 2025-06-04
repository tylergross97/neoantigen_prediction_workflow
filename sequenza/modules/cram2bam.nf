process CRAM2BAM {
	container "community.wave.seqera.io/library/samtools:1.19.1"
	publishDir params.outdir_bam, mode: 'symlink'

	input:
	tuple val(sample_id), path (cram)
	path reference_fasta
	path reference_fai
	path reference_gzi

	output:
	tuple val(sample_id), path("${sample_id}.bam"), emit: bam

	script:
	"""
	ln -s ${reference_fasta} reference.fna.gz
	ln -s ${reference_fai} reference.fna.gz.fai
	ln -s ${reference_gzi} reference.fna.gz.gzi

	samtools view -b -T ${fasta} -o ${sample_id}.bam ${cram}
	"""
}
