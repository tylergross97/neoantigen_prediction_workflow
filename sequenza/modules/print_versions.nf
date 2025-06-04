process PRINT_VERSIONS {
	publishDir params.outdir_versions, mode: 'copy'

	output:
	path "versions.txt"

	script:
	"""
	echo "=== Software Versions ===" > versions.txt
    	java -version 2>&1 | head -1 >> versions.txt
    	nextflow -version >> versions.txt
    	python --version >> versions.txt
    	samtools --version | head -1 >> versions.txt
    	tabix --version 2>&1 | head -1 >> versions.txt
	sequenza-utils --version >> versions.txt
    	echo "=========================" >> versions.txt
	"""
}
