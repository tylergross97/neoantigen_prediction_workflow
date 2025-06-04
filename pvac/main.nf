#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { DOWNLOAD_EXAMPLE_DATA } from './modules/download_example_data.nf'

workflow {
	DOWNLOAD_EXAMPLE_DATA()
}
