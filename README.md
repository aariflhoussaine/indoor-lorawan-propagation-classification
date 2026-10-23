# Indoor LoRaWAN Multi-Environment Dataset and Analysis Code

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23605731.svg)](https://doi.org/10.5281/zenodo.23605731)

This repository accompanies the study:

> Aarif, L., Ahaidous, K., Tabaa, M., Hachimi, H., Monteiro, F. *Empirical
> Characterization and Machine Learning-Based Classification of Indoor LoRaWAN
> Propagation Environments.* 

It provides the complete raw dataset and all analysis code needed to reproduce
every figure and table in the paper.

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
  correlations (Figure 13), and Packet Delivery Rate with Wilson confidence
  intervals (Table 7). See
  [`Experimental Results Analysis/README.md`](Experimental%20Results%20Analysis/README.md).

- **[`Machine Learning-Based Environment Classification/`](Machine%20Learning-Based%20Environment%20Classification/)**
  — A single Jupyter notebook reproducing the entire machine learning
  pipeline in Section 4.2: feature engineering, PCA/t-SNE visualization and
  cluster-quality metrics, an 18-classifier comparison with statistical
  significance testing, group-aware (node-level) validation, confusion and
  ROC analysis, permutation importance and feature ablation, and inference
  latency benchmarking. See
  [`Machine Learning-Based Environment Classification/README.md`](Machine%20Learning-Based%20Environment%20Classification/README.md).

## Data Availability

The complete dataset (43,100 packets, across the four indoor environments
described in Section 3.2 of the paper) is publicly available in this
repository, under [`Dataset/`](Dataset/).

## Reproducing the Paper's Results

1. **Radio-link characterization (Section 4.1, Figures 10–13, Table 7):**
   open MATLAB in the `Experimental Results Analysis/` folder and run each
   script directly (see that folder's README for details and script-to-figure
   mapping).
2. **Machine learning classification (Section 4.2, Figures 14–20, Tables
   8–10 and all supplementary tables):** open the notebook in
   `Machine Learning-Based Environment Classification/` in Jupyter and run
   all cells top to bottom (see that folder's README for expected runtime
   and dependencies).

## License

See [`LICENSE`](LICENSE).

## Contact

L'houssaine Aarif — l.aarif@emsi.ma
LPRI Laboratory, Moroccan School of Engineering Sciences (EMSI), Casablanca, Morocco
