process INDEX_REFERENCE {
    container "community.wave.seqera.io/library/bwa-mem2_samtools:b7ce408fd27b2698"
    publishDir params.outdir_references, mode: 'symlink'

    input:
    path fasta

    output:
    path "reference.fna.gz", emit: fasta_file
    path "reference.fna.gz.fai", emit: fasta_index
    path "reference.fna.gz.gzi", emit: fasta_gzi
    script:
    """
    gunzip -c ${fasta}> reference.fna
    bgzip reference.fna
    samtools faidx reference.fna.gz
    bgzip -i reference.fna.gz
    """
}
