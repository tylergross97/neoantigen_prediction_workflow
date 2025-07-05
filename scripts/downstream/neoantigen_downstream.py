import argparse
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings("ignore")


def load_data(variants_expression_path, binding_predictions_path):
    variants_expression = pd.read_csv(variants_expression_path)
    binding_predictions = pd.read_csv(binding_predictions_path, sep="\t")
    return variants_expression, binding_predictions


def plot_expression_density(df, outdir, suffix=""):
    plt.figure(figsize=(10, 6))
    sns.kdeplot(df["Expression"], fill=True)
    plt.title(f"Density Plot of Expression Levels{suffix}")
    plt.xlabel("Expression Level")
    plt.ylabel("Density")
    plt.savefig(
        os.path.join(outdir, f"expression_density{suffix}.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def plot_allele_frequency(df, outdir):
    plt.figure(figsize=(10, 6))
    sns.kdeplot(df["AF"], fill=True)
    plt.title("Density Plot of Allele Frequencies of PASSED variants")
    plt.xlabel("AF")
    plt.ylabel("Density")
    plt.savefig(
        os.path.join(outdir, "allele_frequency_passed.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def plot_consequence_count(df, outdir):
    plt.figure(figsize=(12, 8))
    sns.countplot(
        data=df,
        y="Consequence",
        order=df["Consequence"].value_counts().index,
    )
    plt.title("Count of Variants by Consequence (Filtered Data)")
    plt.xlabel("Count")
    plt.ylabel("Consequence")
    plt.savefig(
        os.path.join(outdir, "consequence_count.png"), dpi=300, bbox_inches="tight"
    )
    plt.close()


def plot_true_binders_rank(true_binders, outdir):
    plt.figure(figsize=(10, 6))
    sns.kdeplot(true_binders["rank"], fill=True)
    plt.title("Density Plot of Rank of True Binders")
    plt.xlabel("Rank")
    plt.ylabel("Density")
    plt.savefig(
        os.path.join(outdir, "true_binders_rank_density.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def preprocess_variants_binding(variants_expression, binding_predictions):
    # Ensure 'chr' is at the front of the 'CHROM' column in variants_expression
    variants_expression["CHROM"] = variants_expression["CHROM"].apply(
        lambda x: "chr" + str(x).replace("chr", "") if pd.notnull(x) else x
    )
    variants_expression["POS_int"] = variants_expression["POS"].astype(int)

    # Ensure 'chr' is at the front of the 'chr' column in binding_predictions
    binding_predictions["chr"] = binding_predictions["chr"].apply(
        lambda x: "chr" + str(x).replace("chr", "") if pd.notnull(x) else x
    )
    binding_predictions["pos_int"] = pd.to_numeric(
        binding_predictions["pos"], errors="coerce"
    ).astype("Int64")

    binding_predictions["chr"] = (
        binding_predictions["chr"].astype(str).str.replace(".0", "", regex=False)
    )

    # Drop original 'POS' and 'pos' columns
    variants_expression = variants_expression.drop("POS", axis=1)
    binding_predictions = binding_predictions.drop("pos", axis=1)

    # Rename integer position columns to 'POS'
    variants_expression = variants_expression.rename(columns={"POS_int": "POS"})
    binding_predictions = binding_predictions.rename(columns={"pos_int": "POS"})

    # Rename variants_expression['CHROM'] to variants_expression['chr']
    variants_expression = variants_expression.rename(columns={"CHROM": "chr"})

    return variants_expression, binding_predictions


def merge_and_clean(
    variants_expression_filtered,
    strong_true_binders,
    outdir,
    columns_to_keep_and_rename,
):
    # Merge
    merged_df = pd.merge(
        variants_expression_filtered,
        strong_true_binders,
        left_on="Gene",
        right_on="gene_symbol",
        how="inner",
    )
    merged_df.to_csv(os.path.join(outdir, "merged_df.csv"), index=False)

    # Redundant column checks and cleaning
    redundant_cols = []
    for i in range(len(merged_df.columns)):
        for j in range(i + 1, len(merged_df.columns)):
            col1 = merged_df.columns[i]
            col2 = merged_df.columns[j]
            if col1 != col2 and merged_df[col1].equals(merged_df[col2]):
                redundant_cols.append((col1, col2))

    redundant_cols_dtype_check = []
    cols = merged_df.columns
    for i in range(len(cols)):
        for j in range(i + 1, len(cols)):
            col1_name = cols[i]
            col2_name = cols[j]
            if col1_name != col2_name:
                col1_values = merged_df[col1_name].astype(str)
                col2_values = merged_df[col2_name].astype(str)
                if col1_values.equals(col2_values):
                    redundant_cols_dtype_check.append(
                        (
                            col1_name,
                            col2_name,
                            str(merged_df[col1_name].dtype),
                            str(merged_df[col2_name].dtype),
                        )
                    )

    all_redundant_pairs = redundant_cols + [
        (pair[0], pair[1]) for pair in redundant_cols_dtype_check
    ]
    cols_to_drop = set()
    cols_to_keep = set()
    for col1, col2 in all_redundant_pairs:
        if (
            col1 not in cols_to_keep
            and col1 not in cols_to_drop
            and col2 not in cols_to_keep
            and col2 not in cols_to_drop
        ):
            cols_to_keep.add(col1)
            cols_to_drop.add(col2)
        elif col1 in cols_to_keep:
            cols_to_drop.add(col2)
        elif col2 in cols_to_keep:
            cols_to_drop.add(col1)
        elif col1 in cols_to_drop:
            cols_to_keep.add(col2)
            cols_to_drop.remove(col1)
        elif col2 in cols_to_drop:
            cols_to_keep.add(col1)
            cols_to_drop.remove(col2)
    cols_to_drop_list = list(cols_to_drop)
    merged_df_cleaned = merged_df.drop(columns=cols_to_drop_list)

    # Final column selection and renaming
    existing_cols = [
        col
        for col in columns_to_keep_and_rename.keys()
        if col in merged_df_cleaned.columns
    ]
    merged_df_final2 = merged_df_cleaned[existing_cols].rename(
        columns={col: columns_to_keep_and_rename[col] for col in existing_cols}
    )
    desired_order = [
        col
        for col in columns_to_keep_and_rename.values()
        if col in merged_df_final2.columns
    ]
    merged_df_final2 = merged_df_final2[desired_order]

    merged_df_final2.to_csv(os.path.join(outdir, "merged_df_final2.csv"), index=False)
    return merged_df_final2


def process_neoantigen_downstream(
    variants_expression_path, binding_predictions_path, outdir
):
    os.makedirs(outdir, exist_ok=True)
    variants_expression, binding_predictions = load_data(
        variants_expression_path, binding_predictions_path
    )

    # --- VEP annotation check ---
    required_vep_columns = ["Gene", "Transcript_ID", "Consequence"]
    missing_vep = [
        col for col in required_vep_columns if col not in variants_expression.columns
    ]
    empty_vep = [
        col
        for col in required_vep_columns
        if col in variants_expression.columns
        and variants_expression[col].dropna().empty
    ]
    # Raise error if VEP annotation is missing or empty
    if missing_vep:
        raise ValueError(
            f"Input file '{variants_expression_path}' is not VEP annotated. "
            f"Missing columns: {', '.join(missing_vep)}; "
            f"Empty columns: {', '.join(empty_vep)}"
        )

    # Info
    variants_expression.info()
    binding_predictions.info()

    # Clean and filter
    nan_expression_count = variants_expression["Expression"].isnull().sum()
    print(
        f"Number of rows with NaN values in 'Expression' column: {nan_expression_count}"
    )
    variants_expression_cleaned = variants_expression.dropna(subset=["Expression"])
    print(
        "Number of rows after removing NaN values in 'Expression':",
        len(variants_expression_cleaned),
    )

    plot_expression_density(variants_expression_cleaned, outdir)

    variants_expression_filtered = variants_expression_cleaned[
        (variants_expression_cleaned["Filter"].str.contains("PASS"))
        & (variants_expression_cleaned["Expression"] != 0)
    ]
    print("Number of rows after filtering:", len(variants_expression_filtered))
    print(variants_expression_filtered.head())

    plot_expression_density(variants_expression_filtered, outdir, "_passed")
    plot_allele_frequency(variants_expression_filtered, outdir)
    plot_consequence_count(variants_expression_filtered, outdir)

    # Binding predictions
    print(binding_predictions.head())
    print(binding_predictions["binder"].value_counts())

    true_binders = binding_predictions[binding_predictions["binder"] == True]
    print(true_binders.head())
    true_binders.info()

    plot_true_binders_rank(true_binders, outdir)

    strong_true_binders = true_binders[true_binders["rank"] < 0.5]
    print(strong_true_binders.head())

    # Join and preprocess
    variants_expression, binding_predictions = preprocess_variants_binding(
        variants_expression, binding_predictions
    )

    variants_expression["chr_pos"] = (
        variants_expression["chr"].astype(str)
        + "_"
        + variants_expression["POS"].astype(str)
    )
    binding_predictions["chr_pos"] = (
        binding_predictions["chr"].astype(str)
        + "_"
        + binding_predictions["POS"].astype(str)
    )

    # mygene lookup (optional)
    try:
        import mygene

        mg = mygene.MyGeneInfo()
        gene_ids = (
            strong_true_binders["gene"].dropna().str.split(".").str[0].unique().tolist()
        )
        gene_info = mg.querymany(
            gene_ids, scopes="ensembl.gene", fields="symbol", species="human"
        )
        gene_symbol_map = {g["query"]: g.get("symbol", "Unknown") for g in gene_info}
        strong_true_binders["gene_symbol"] = (
            strong_true_binders["gene"]
            .dropna()
            .str.split(".")
            .str[0]
            .map(gene_symbol_map)
        )
        print(strong_true_binders[["gene", "gene_symbol"]].head())
    except ImportError:
        print("mygene not installed; skipping gene symbol mapping.")

    columns_to_keep_and_rename = {
        "chr_pos": "chr_pos",
        "REF": "REF",
        "ALT": "ALT",
        "Filter": "Filter",
        "Gene": "gene_symbol",
        "sequence": "sequence",
        "gene": "gene_id",
        "Transcript_ID": "transcript_id",
        "proteins": "protein_id",
        "Consequence": "variant_type",
        "Expression": "transcript_expression",
        "gnomAD_AF": "gnomAD_AF",
        "refseq": "refseq",
        "uniprot": "uniprot",
        "synonymous": "synonymous",
        "PV1_DNA1.DP": "PV1_DNA1.DP",
        "PV1_RCC.SB": "PV1_RCC.SB",
        "PV1_DNA1.AF": "PV1_DNA1.AF",
        "ROQ": "ROQ",
        "MMQ": "MMQ",
        "MBQ": "MBQ",
        "PV1_RCC.AD": "PV1_RCC.AD",
        "PV1_DNA1.F2R1": "PV1_DNA1.F2R1",
        "TLOD": "TLOD",
        "AS_SB_TABLE": "AS_SB_TABLE",
        "MPOS": "MPOS",
        "PV1_DNA1.SB": "PV1_DNA1.SB",
        "POPAF": "POPAF",
        "NALOD": "NALOD",
        "PV1_RCC.FAD": "PV1_RCC.FAD",
        "MFRL": "MFRL",
        "DP": "DP",
        "PV1_RCC.F2R1": "PV1_RCC.F2R1",
        "PV1_RCC.AF": "PV1_RCC.AF",
        "GERMQ": "GERMQ",
        "PV1_DNA1.AD": "PV1_DNA1.AD",
        "AS_FilterStatus": "AS_FilterStatus",
        "PV1_DNA1.FAD": "PV1_DNA1.FAD",
        "ECNT": "ECNT",
        "NLOD": "NLOD",
        "PV1_RCC.GT": "PV1_RCC.GT",
        "PV1_DNA1.GT": "PV1_DNA1.GT",
        "PV1_DNA1.F1R2": "PV1_DNA1.F1R2",
        "PV1_RCC.F1R2": "PV1_RCC.F1R2",
        "PV1_RCC.DP": "PV1_RCC.DP",
        "allele": "hla_allele",
        "rank": "binding_rank",
        "BA": "binding_affinity",
        "binder": "binder",
        "predictor": "predictor",
        "RPA": "RPA",
        "STRQ": "STRQ",
        "STR": "STR",
        "RU": "RU",
    }

    merged_df_final2 = merge_and_clean(
        variants_expression_filtered,
        strong_true_binders,
        outdir,
        columns_to_keep_and_rename,
    )
    print(merged_df_final2.head())
    return merged_df_final2


def main():
    parser = argparse.ArgumentParser(description="Neoantigen downstream analysis")
    parser.add_argument(
        "--variants_expression",
        required=True,
        help="Path to CSV file from vcf_to_csv.py",
    )
    parser.add_argument(
        "--binding_predictions",
        required=True,
        help="Path to epitope prediction TSV file",
    )
    parser.add_argument(
        "--outdir", required=True, help="Directory to save plots and final CSV"
    )
    args = parser.parse_args()
    process_neoantigen_downstream(
        args.variants_expression, args.binding_predictions, args.outdir
    )


if __name__ == "__main__":
    main()
