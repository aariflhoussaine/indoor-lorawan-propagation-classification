# Machine Learning-Based Environment Classification

A single Jupyter notebook, `lorawan_ml_classification.ipynb`, reproducing the
machine learning pipeline described in Section 4.2 of the paper, from raw
packet data to every ML-related figure and table.

## What This Notebook Does

The notebook is organized into numbered steps, each producing one or more
figures/tables saved to `results_ML/` (created automatically on first run):

| Step | Content | Paper reference |
|---|---|---|
| 1 | Data loading and feature engineering (9 features per packet) | Section 4.2.1 |
| 1b | ANOVA / Kruskal-Wallis significance test on RSSI and SNR across environments | Section 4.1.3 |
| 1c | Packet distribution per physical node and per collection day | Sections 3.2, 5.2.5 |
| 2 | PCA and t-SNE visualization | Figure 14 |
| — | Cluster-quality metrics (silhouette, Davies-Bouldin) on the full feature space, PCA, and t-SNE | Section 4.2.1 |
| 3 | Comparison of 18 classifiers across 7 algorithmic families, nested cross-validation (outer stratified 5-fold, inner 3-fold GridSearchCV, scaler inside the pipeline) | Table 9, Figure 15 |
| 3a | Paired t-test for statistical significance between the top classifiers | Table 10, Section 4.2.3 |
| 3b | Majority-class and RSSI-threshold baselines; **group-aware (node-level) validation** with five groupings (deployment, device label, physical board) | Table 11, Section 4.2.4 |
| 3b | Variance of the frequency offset explained by board, deployment and environment (η²) | Section 5.2.3 |
| 4 | Detailed evaluation of the best model on the 25 % hold-out test set: confusion matrix, per-class precision/recall/F1, one-vs-rest ROC curves and **precision-recall curves** | Figures 16–18, Table 12 |
| 5 | Permutation feature importance | Figure 19, Table 14 |
| 5b | Feature ablation study (drop-one-feature retraining) | Table 13 |
| 5c | SHAP analysis (optional, complements permutation importance) | — |
| 6 | Average per-class feature profile (radar chart) | Figure 20 |
| 7 | Example single-packet environment prediction | — |
| 8 | Single-packet inference latency (best model, 20,000 repetitions) | Figure 21, Section 4.2.7 |
| 8b | Inference latency across all 18 classifiers | Figure 22, Section 4.2.8 |

Figures are saved as `Fig14` ... `Fig22` with the **same numbers as in the
paper** (Fig18 = precision-recall curves, Fig19 = permutation importance,
Fig20 = radar profiles, Fig21 = CatBoost latency, Fig22 = latency of all
classifiers). The tables keep the names of the CSV files written by the
notebook; their correspondence with the paper tables is:

| CSV file | Paper table |
|---|---|
| `Table8_cv_results.csv` | Table 9 (18 classifiers, nested CV) |
| `Table_ModelSignificance.csv` | Table 10 |
| `Table_GroupCV.csv`, `Table_GroupCV_folds.csv` | Table 11 (and fold-level details) |
| `Table_ClassificationReport.csv`, `Table_ConfusionMatrix.csv` | Table 12 and Figure 16 |
| `Table_Ablation.csv` | Table 13 |
| `Table9_feature_importance.csv` | Table 14 |
| `Table_AUC.csv`, `Table_AveragePrecision.csv` | ROC (Figure 17) and precision-recall (Figure 18) values |
| `Table_FreqOffset_Eta2.csv` | η² of the frequency offset (Section 5.2.3) |
| `Table_InferenceLatency.csv`, `Table_LatencyAllModels.csv` | Sections 4.2.7 and 4.2.8 |
| `Table_ANOVA_RSSI_SNR.csv`, `Table_ClusterQuality.csv` | Sections 4.1.3 and 4.2.1 |
| `Table_PacketsPerNode.csv`, `Table_PacketsPerDay.csv`, `Table_TemporalSpan.csv` | Sections 3.2 and 5.2.5 |

The folder [`results_ML/`](results_ML/) contains the CSV files produced by the
run reported in the paper, and `results_ML/figures_as_in_paper/` contains the
corresponding figures in PDF format.

## Validation Protocols

* **Packet-level (nested) cross-validation** (Table 9): packets are split at
  random, so packets of one node appear in training and test folds.
* **25 % hold-out test set** (Table 12, Figures 16–19): the scaler and the
  hyperparameters are fitted on the 75 % training split only.
* **Group-aware validation** (Table 11): entire nodes are held out. Groupings:
  environment + `Device_ID` (26 deployments), `Device_ID` only (16 labels), and
  physical board (9 boards). The same nine boards were used in all four
  environments and `Nodek` (residential) corresponds to `noeudk` in the other
  environments, so the board is identified by the digit of the label (see
  [`../Dataset/Board_Mapping.csv`](../Dataset/Board_Mapping.csv)). With every
  grouping the accuracy is below the majority-class rate (30.2 %), i.e. the
  classifier recognizes the nodes of the dataset rather than a generalizable
  environment signature. Fold-level scores are noisy because some test folds
  contain only part of the four classes.

## Data Source

The notebook reads the seven aggregate CSV files from
[`../Dataset/By_Environment_and_Condition/`](../Dataset/By_Environment_and_Condition/)
(the `DATA_DIR` variable near the top of the notebook is already set to this
path). These are the same files used by four of the five MATLAB scripts in
[`../Experimental Results Analysis/`](../Experimental%20Results%20Analysis/);
the notebook does not duplicate any data.

## Running the Notebook

```bash
cd "Machine Learning-Based Environment Classification"
pip install -r requirements.txt
jupyter notebook lorawan_ml_classification.ipynb
```

`requirements.txt` lists the library versions of the environment in which the
reported results were produced (Python 3.13.9, scikit-learn 1.7.2, statsmodels
0.14.5, XGBoost 3.2.0, LightGBM 4.6.0, CatBoost 1.2.10, NumPy 2.4.4, pandas
3.0.2, SciPy 1.16.3, Matplotlib 3.10.6). Other versions may work but can
change numerical results slightly (particularly for XGBoost, LightGBM,
CatBoost and t-SNE).

Run all cells top to bottom. The run can take several hours on a commodity
machine, dominated by the nested cross-validation of
18 classifiers (Step 3), the group-aware validation (Step 3b) and the
per-classifier latency benchmark (Step 8b).

**Optional dependencies.** `xgboost`, `lightgbm`, and `catboost` are used if
available (three of the best-performing classifiers, CatBoost being the
reference classifier) but the notebook degrades gracefully, printing a warning
and skipping that classifier, if any of them is not installed. `shap` (Step 5c)
is entirely optional.

## Random Seed

`RANDOM_STATE = 42` is fixed once near the top of the notebook and reused for
every stochastic operation (train/test split, cross-validation folds, PCA,
t-SNE and its 5,000-point subsample, permutation importance, model
initialization). Because several steps run in parallel, the last decimal of a
metric can vary slightly between runs and library versions; the latencies
depend on the machine and are given for orders of magnitude only.

## Output

All figures (`.pdf` and `.png`) and tables (`.csv`) are written to
`results_ML/`, created relative to this folder.
