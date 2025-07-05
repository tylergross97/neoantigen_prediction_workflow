import os
import pandas as pd
import pytest
from scripts.downstream.neoantigen_downstream import (
    load_data,
    preprocess_variants_binding,
    merge_and_clean,
    process_neoantigen_downstream,
)


def test_load_data(tmp_path):
    variants_csv = tmp_path / "variants.csv"
    binding_tsv = tmp_path / "binding.tsv"
    pd.DataFrame({"A": [1], "B": [2]}).to_csv(variants_csv, index=False)
    pd.DataFrame({"C": [3], "D": [4]}).to_csv(binding_tsv, sep="\t", index=False)
    v, b = load_data(variants_csv, binding_tsv)
    assert not v.empty
    assert not b.empty


def test_preprocess_variants_binding():
    variants = pd.DataFrame({"CHROM": ["1"], "POS": [123]})
    binding = pd.DataFrame({"chr": ["1"], "pos": [123]})
    v2, b2 = preprocess_variants_binding(variants, binding)
    assert "chr" in v2.columns
    assert "POS" in v2.columns
    assert "chr" in b2.columns
    assert "POS" in b2.columns


def test_merge_and_clean(tmp_path):
    variants = pd.DataFrame(
        {
            "Gene": ["GENE1"],
            "Expression": [1.0],
            "Filter": ["PASS"],
            "chr": ["chr1"],
            "POS": [123],
            "chr_pos": ["chr1_123"],
        }
    )
    binders = pd.DataFrame(
        {
            "gene_symbol": ["GENE1"],
            "chr": ["chr1"],
            "POS": [123],
            "chr_pos": ["chr1_123"],
        }
    )
    columns_to_keep_and_rename = {"Gene": "gene_symbol", "chr_pos": "chr_pos"}
    outdir = tmp_path
    result = merge_and_clean(variants, binders, outdir, columns_to_keep_and_rename)
    assert not result.empty
    assert os.path.exists(os.path.join(outdir, "merged_df_final2.csv"))


def test_process_neoantigen_downstream_success(tmp_path):
    variants = pd.DataFrame(
        {
            "CHROM": ["1"],
            "POS": [123],
            "Filter": ["PASS"],
            "Expression": [1.0],
            "Gene": ["GENE1"],
            "Transcript_ID": ["TX1"],
            "Consequence": ["missense_variant"],
            "AF": [0.5],
        }
    )
    binding = pd.DataFrame(
        {
            "chr": ["1"],
            "pos": [123],
            "binder": [True],
            "rank": [0.1],
            "gene": ["GENE1.1"],
            "transcripts": ["TX1"],
        }
    )
    variants_path = tmp_path / "variants.csv"
    binding_path = tmp_path / "binding.tsv"
    variants.to_csv(variants_path, index=False)
    binding.to_csv(binding_path, sep="\t", index=False)
    outdir = tmp_path / "out"
    result = process_neoantigen_downstream(variants_path, binding_path, outdir)
    assert os.path.exists(os.path.join(outdir, "merged_df_final2.csv"))
    assert isinstance(result, pd.DataFrame)


def test_process_neoantigen_downstream_raises_on_missing_vep_columns(tmp_path):
    variants = pd.DataFrame(
        {
            "CHROM": ["1"],
            "POS": [123],
            "Filter": ["PASS"],
            "Expression": [1.0],
            # "Gene", "Transcript_ID", "Consequence" are missing
        }
    )
    binding = pd.DataFrame(
        {
            "chr": ["1"],
            "pos": [123],
            "binder": [True],
            "rank": [0.1],
            "gene": ["GENE1.1"],
            "transcripts": ["TX1"],
        }
    )
    variants_path = tmp_path / "variants.csv"
    binding_path = tmp_path / "binding.tsv"
    variants.to_csv(variants_path, index=False)
    binding.to_csv(binding_path, sep="\t", index=False)
    outdir = tmp_path / "out"
    with pytest.raises(ValueError, match="is not VEP annotated"):
        process_neoantigen_downstream(variants_path, binding_path, outdir)
