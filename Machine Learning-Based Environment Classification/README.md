# Machine Learning-Based Environment Classification

A single Jupyter notebook, `lorawan_ml_classification.ipynb`, reproducing the
entire machine learning pipeline described in Section 4.2 of the paper, from
raw packet data to every ML-related figure and table.

## What This Notebook Does

The notebook is organized into numbered steps, each producing one or more
figures/tables saved to `results_ML/` (created automatically on first run):

| Step | Content | Paper reference |
|---|---|---|
| 1 | Data loading and feature engineering (9 features per packet) | Section 4.2.1 |
| 1b | ANOVA / Kruskal-Wallis significance test on RSSI and SNR across environments | Section 4.1.3 |
| 1c | Packet distribution per physical node and per collection day | Section 3.2 |
| 2 | PCA and t-SNE visualization | Figure 14 |
| — | Cluster-quality metrics (silhouette, Davies-Bouldin) on the full feature space, PCA, and t-SNE | Section 4.2.1 |
| 3 | Comparison of 18 classifiers across 7 algorithmic families (GridSearchCV + 5-fold CV) | Table 8, Figure 15 |
| 3a | Paired t-test for statistical significance between the top classifiers | Section 4.2.3 |
| 3b | Majority-class and RSSI-threshold baselines; group-aware (node-level) cross-validation | Section 4.2.4 |
| 4 | Detailed evaluation of the best model: confusion matrix, per-class precision/recall/F1, ROC curves | Figures 16–17, Table 9 |
| 5 | Permutation feature importance | Figure 18, Table 10 |
| 5b | Feature ablation study (drop-one-feature retraining) | Section 4.2.5 |
| 5c | SHAP analysis (optional, complements permutation importance) | Section 4.2.5 |
| 6 | Average per-class feature profile (radar chart) | Figure 19 |
| 7 | Example single-packet environment prediction | — |
| 8 | Single-packet inference latency (best model, 20,000 repetitions) | Figure 20 |
| 8b | Inference latency across all 18 classifiers | Section 4.2.7 |

This single notebook is intentionally kept as one file rather than split into
per-step scripts, so that every later step can directly reuse variables
computed earlier (`df_all`, `X_scaled`, `results`, `best_models`, `cv_outer`,
etc.) instead of recomputing them — avoiding the code duplication that would
result from re-loading or re-training in multiple separate files.

## Data Source

The notebook reads the seven aggregate CSV files from
[`../Dataset/By_Environment_and_Condition/`](../Dataset/By_Environment_and_Condition/)
(the `DATA_DIR` variable near the top of the notebook is already set to this
path). These are the same files used by four of the five MATLAB scripts in
[`../Experimental Results Analysis/`](../Experimental%20Results%20Analysis/)
— the notebook does not duplicate any data.

## Running the Notebook

```bash
cd "Machine Learning-Based Environment Classification"
pip install -r requirements.txt
jupyter notebook lorawan_ml_classification.ipynb
```

Run all cells top to bottom. Expected runtime is roughly 30–90 minutes on a
commodity machine, dominated by the GridSearchCV comparison across 18
classifiers (Step 3) and the per-classifier latency benchmark (Step 8b).

**Optional dependencies.** `xgboost`, `lightgbm`, and `catboost` are used if
available (three of the best-performing classifiers) but the notebook
degrades gracefully — printing a warning and skipping that classifier — if
any of them is not installed. `shap` (Step 5c) is entirely optional and is
skipped with a message if not installed.

## Random Seed

`RANDOM_STATE = 42` is fixed once near the top of the notebook and reused for
every stochastic operation (train/test split, cross-validation folds, PCA,
t-SNE, permutation importance, model initialization), so re-running the
notebook reproduces the exact figures reported in the paper.

## Output

All figures (`.pdf` and `.png`) and tables (`.csv`) are written to
`results_ML/`, created relative to this folder. File names match the figure
and table numbers used in the manuscript wherever a direct correspondence
exists (e.g. `Fig14.pdf`, `Table8_cv_results.csv`).
