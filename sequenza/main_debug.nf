#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { PRINT_VERSIONS } from './modules/print_versions.nf'
include { GC_WIGGLE } from './modules/gc_wiggle.nf'
include { FASTP } from './modules/fastp.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { INDEX_HUMAN } from './modules/index_human.nf'
include { BWAMEM2_ALIGN } from './modules/bwamem2_align.nf'
include { INDEX_BAM } from './modules/index_bam.nf'
include { SORT_BAM } from './modules/sort_bam.nf'
include { BAM2SEQZ } from './modules/bam2seqz.nf'

workflow {
    // Create fasta channel
    Channel
        .fromPath(params.fasta)
        .set { fasta_ch }

    // Create file pairs for reads
    reads_ch = Channel
        .fromFilePairs("${params.reads_dir}/*_{1,2}.fastq.gz", checkIfExists: false)
        .filter { key, _files -> key in params.sample_ids }

    // Debug: Show what samples we found
    reads_ch.view { "Found sample: $it" }

    // Run initial processes
    PRINT_VERSIONS()
    GC_WIGGLE(params.fasta)
    human_index = INDEX_HUMAN(params.fasta)
    FASTP(reads_ch)
    BWAMEM2_ALIGN(FASTP.out.trimmed_reads, human_index)
    SORT_BAM(BWAMEM2_ALIGN.out)
    INDEX_BAM(SORT_BAM.out)

    // Debug: Show what INDEX_BAM outputs
    INDEX_BAM.out.indexed_bam.view { "INDEX_BAM output: $it" }

    // Create separate channels for tumor and normal samples
    tumor_bam_ch = INDEX_BAM.out.indexed_bam
        .filter { sample_id, bam, bai -> 
            println "Checking sample: $sample_id against tumor_id: ${params.tumor_id}"
            sample_id == params.tumor_id 
        }
        .map { sample_id, bam, bai -> 
            println "Tumor BAM found: $bam, BAI: $bai"
            tuple(bam, bai) 
        }

    normal_bam_ch = INDEX_BAM.out.indexed_bam
        .filter { sample_id, bam, bai -> 
            println "Checking sample: $sample_id against normal_id: ${params.normal_id}"
            sample_id == params.normal_id 
        }
        .map { sample_id, bam, bai -> 
            println "Normal BAM found: $bam, BAI: $bai"
            tuple(bam, bai) 
        }

    // Debug: Show tumor and normal channels
    tumor_bam_ch.view { "Tumor BAM channel: $it" }
    normal_bam_ch.view { "Normal BAM channel: $it" }

    // Combine all inputs for BAM2SEQZ
    bam2seqz_input_ch = tumor_bam_ch
        .combine(normal_bam_ch)
        .combine(GC_WIGGLE.out.gc_wiggle_track)
        .combine(fasta_ch)
        .map { tumor_bam, tumor_bai, normal_bam, normal_bai, gc_wiggle, fasta ->
            println "Creating BAM2SEQZ input tuple:"
            println "  Tumor BAM: $tumor_bam"
            println "  Normal BAM: $normal_bam" 
            println "  Tumor BAI: $tumor_bai"
            println "  Normal BAI: $normal_bai"
            println "  GC Wiggle: $gc_wiggle"
            println "  FASTA: $fasta"
            tuple(tumor_bam, normal_bam, tumor_bai, normal_bai, gc_wiggle, fasta)
        }

    // Final debug: Print what we're passing to BAM2SEQZ
    bam2seqz_input_ch.view { "Final BAM2SEQZ input: $it" }

    // Run BAM2SEQZ
    BAM2SEQZ(bam2seqz_input_ch)
}
