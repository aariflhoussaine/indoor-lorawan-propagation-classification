# Indoor LoRaWAN Multi-Environment Dataset and Analysis Code

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23605731.svg)](https://doi.org/10.5281/zenodo.23605731)

This repository accompanies the study:

> Aarif, L., Ahaidous, K., Tabaa, M., Hachimi, H., Monteiro, F. *Empirical
> Characterization and Machine Learning-Based Classification of Indoor LoRaWAN
> Propagation Environments.* 

It provides the complete raw dataset and the analysis code used for every figure
and table in the paper. The measurement campaigns themselves cannot be
reproduced exactly (see "Scope and Limitations" below).

This version (v2.1) is permanently archived on Zenodo
(DOI: [10.5281/zenodo.23605731](https://doi.org/10.5281/zenodo.23605731)).
The DOI [10.5281/zenodo.23599850](https://doi.org/10.5281/zenodo.23599850)
always resolves to the latest version.

## Repository Structure

```
repo_root/
├── Dataset/
│   ├── By_Environment_and_Condition/   <- aggregate CSVs (43,100 packets)
│   └── By_Environment_and_Node/        <- raw per-node CSVs, for PDR only
├── Experimental Results Analysis/      <- MATLAB scripts (Section 4.1)
├── Machine Learning-Based Environment Classification/  <- Python notebook (Section 4.2)
└── LICENSE
```

- **[`Dataset/`](Dataset/)** — All raw measurement data, in two forms
  described below. See [`Dataset/README.md`](Dataset/README.md) for the full
  data dictionary and collection methodology.

- **[`Experimental Results Analysis/`](Experimental%20Results%20Analysis/)**
  — MATLAB scripts reproducing the empirical radio-link characterization in
  Section 4.1 of the paper: RSSI distributions (Figure 10), frequency
  resilience (Figure 11), SNR distributions (Figure 12), SNR-RSSI-distance
  correlations (Figure 13) with Spearman coefficients (Table 7), and Packet
  Delivery Rate with Wilson confidence intervals (Table 8). See
  [`Experimental Results Analysis/README.md`](Experimental%20Results%20Analysis/README.md).

- **[`Machine Learning-Based Environment Classification/`](Machine%20Learning-Based%20Environment%20Classification/)**
  — A single Jupyter notebook reproducing the entire machine learning
  pipeline in Section 4.2: feature engineering, PCA/t-SNE visualization and
  cluster-quality metrics, an 18-classifier comparison with nested
  cross-validation and statistical significance testing, group-aware
  (node-level and physical-board) validation, confusion, ROC and
  precision-recall analysis, permutation importance and feature ablation, and
  inference latency benchmarking. See
  [`Machine Learning-Based Environment Classification/README.md`](Machine%20Learning-Based%20Environment%20Classification/README.md).

## Data Availability

The complete dataset (43,100 packets, across the four indoor environments
described in Section 3.2 of the paper) is publicly available in this
repository, under [`Dataset/`](Dataset/).

## Reproducing the Paper's Results

1. **Radio-link characterization (Section 4.1, Figures 10–13, Tables 7–8):**
   open MATLAB in the `Experimental Results Analysis/` folder and run each
   script directly (see that folder's README for details and script-to-figure
   mapping).
2. **Machine learning classification (Section 4.2, Figures 14–22, Tables
   9–14 and the supplementary tables):** open the notebook in
   `Machine Learning-Based Environment Classification/` in Jupyter and run
   all cells top to bottom (see that folder's README for expected runtime
   and dependencies).

## Scope and Limitations

* The raw data and analysis scripts are public, but the campaigns cannot be
  reproduced exactly: the Node-RED flow is provided for the underground
  industrial environment only, the per-campaign The Things Stack release, the
  ADR convergence, collision counts and the antenna gain were not recorded.
* The same nine physical boards were used in all four environments (see
  [`Dataset/Board_Mapping.csv`](Dataset/Board_Mapping.csv)); environment identity is
  therefore confounded with node placement and recording session.
* The machine learning classifier recognizes the nodes of the dataset: with
  node-level validation its accuracy (22–28 %) falls below the majority-class
  rate (30.2 %). It is intended for monitoring a registered set of nodes, not
  for classifying new installations.
* The packet delivery rate is computed within the window between the first and
  last packet received from each node, and its Wilson intervals are
  descriptive (packets of a node are correlated).

## License

See [`LICENSE`](LICENSE).

## Contact

L'houssaine Aarif — l.aarif@emsi.ma
LPRI Laboratory, Moroccan School of Engineering Sciences (EMSI), Casablanca, Morocco
