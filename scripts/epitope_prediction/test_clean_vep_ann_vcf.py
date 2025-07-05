import pytest

# Import the functions to be tested from the main script
# Assuming the functions are defined in a file named clean_vep_ann_vcf.py in the same directory
from clean_vep_ann_vcf import clean_annotation_field, clean_vcf_line


def test_clean_annotation_field():
    assert clean_annotation_field("?") == "1"
    assert clean_annotation_field("?-1/8553") == "1/8553"
    assert clean_annotation_field("3107-?/3108") == "3107/3108"
    assert clean_annotation_field("1036-?/1035") == "1036/1035"
    assert clean_annotation_field("?/1000") == "1/1000"
    assert clean_annotation_field("1234") == "1234"
    assert clean_annotation_field("") == ""
    assert clean_annotation_field(None) == ""


def test_clean_vcf_line():
    # Example VCF line with problematic CSQ fields
    line = "chr1\t123456\t.\tA\tT\t.\t.\tCSQ=ENST00000367770|?|?|?|?|?|?|?|?|?|?|?|?-1/8553|3107-?/3108|1036-?/1035|?|?;ANOTHER=VALUE\n"
    cleaned = clean_vcf_line(line)
    assert "1/8553" in cleaned
    assert "3107/3108" in cleaned
    assert "1036/1035" in cleaned

    # Line without CSQ should be unchanged
    line2 = "chr1\t123456\t.\tA\tT\t.\t.\tSOMEFIELD=VALUE\n"
    assert clean_vcf_line(line2) == line2

    # Header line should be unchanged
    header = "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n"
    assert clean_vcf_line(header) == header
