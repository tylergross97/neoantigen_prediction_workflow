import os
import gzip
import shutil
import csv
from vcf_to_csv import vcf_to_csv

def test_vcf_to_csv(tmp_path):
    # Prepare a minimal VCF file
    vcf_content = """##fileformat=VCFv4.2
##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Feature|SYMBOL|HGVSp|Consequence|gnomADe_AF|gnomADg_AF">
#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tTUMOR
1\t1000\t.\tA\tT\t.\tPASS\tCSQ=ENST00000367770|GENE1|p.Val600Glu|missense_variant|0.01|0.02\tAF:TX\t0.5:ENST00000367770|10.0
"""
    vcf_path = tmp_path / "test.vcf"
    with open(vcf_path, "w") as f:
        f.write(vcf_content)
    # Optionally gzip the file if your script expects .vcf.gz
    vcf_gz_path = str(vcf_path) + ".gz"
    with open(vcf_path, "rb") as f_in, gzip.open(vcf_gz_path, "wb") as f_out:
        shutil.copyfileobj(f_in, f_out)

    output_csv = tmp_path / "output.csv"
    vcf_to_csv(vcf_gz_path, str(output_csv), "TUMOR")

    # Check output CSV
    with open(output_csv) as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        assert len(rows) == 1
        assert rows[0]["Gene"] == "GENE1"
        assert rows[0]["Transcript_ID"] == "ENST00000367770"
        assert rows[0]["Expression"] == "10.0"