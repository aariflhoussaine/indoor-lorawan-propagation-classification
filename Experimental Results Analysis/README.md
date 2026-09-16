# Experimental Results Analysis

MATLAB scripts reproducing the empirical radio link characterization
presented in Section 4.1 of the paper (RSSI, frequency resilience, SNR,
multi-dimensional correlation, and Packet Delivery Rate). This folder
contains **scripts only** — all data is kept separately under
[`../Dataset/`](../Dataset/), so the same raw files can be reused by both the
MATLAB scripts here and the Python notebook in
[`../Machine Learning-Based Environment Classification/`](../Machine%20Learning-Based%20Environment%20Classification/)
without duplication.

## Scripts and Corresponding Paper Output

| Script | Paper figure/table | Reads from | Description |
|---|---|---|---|
| `rssi_boxplot_by_environment.m` | Figure 10 | `Dataset/By_Environment_and_Condition/` | RSSI distribution across environments, conditions and scenarios |
| `rssi_vs_frequency.m` | Figure 11 | `Dataset/By_Environment_and_Condition/` | Average RSSI per frequency channel, with ±1 SD error bars |
| `snr_histograms_by_environment.m` | Figure 12 | `Dataset/By_Environment_and_Condition/` | SNR distribution (relative-frequency histograms, 0.25 dB bins) |
| `correlation_3d.m` | Figure 13 | `Dataset/By_Environment_and_Condition/` | SNR–RSSI–distance 3D scatter plots, one panel per environment |
| `CalculPDR.m` | Table 7 | `Dataset/By_Environment_and_Node/` | Per-node Packet Delivery Rate, pooled per environment/condition with 95% Wilson confidence intervals |
| `wilson_ci.m` | (used by `CalculPDR.m`) | — | Wilson score confidence interval for a binomial proportion (helper function, not run directly) |

## Data Sources — Two Different Granularities

Four of the six scripts above (`rssi_boxplot_by_environment.m`,
`rssi_vs_frequency.m`, `snr_histograms_by_environment.m`, `correlation_3d.m`)
read the **aggregate, per-environment-and-condition** CSV files from
[`../Dataset/By_Environment_and_Condition/`](../Dataset/By_Environment_and_Condition/).
These files contain only successfully received packets and are sufficient
for RSSI/SNR/frequency/distance analysis.

`CalculPDR.m` is the exception: computing a Packet Delivery Rate requires
knowing every transmission *attempt*, including packets that were never
received, which is only recoverable from the **per-node** raw files (one CSV
per physical node, spanning its full transmission timeline) in
[`../Dataset/By_Environment_and_Node/`](../Dataset/By_Environment_and_Node/).
This is why PDR calculation uses a separate, finer-grained data source.

## Running the Scripts

All scripts assume MATLAB's current working directory is this folder
(`Experimental Results Analysis/`) and use relative paths (`../Dataset/...`)
accordingly. Each script can be run independently and directly (no shared
setup script is required); each writes its output figure(s) and a CSV of the
exact plotted values into this same folder.

```matlab
% From within MATLAB, with the current folder set to
% "Experimental Results Analysis/":
run('rssi_boxplot_by_environment.m')
run('rssi_vs_frequency.m')
run('snr_histograms_by_environment.m')
run('correlation_3d.m')
run('CalculPDR.m')   % also prints a ready-to-paste LaTeX version of Table 7
```

## Notes on `CalculPDR.m`

- Consolidates what were previously four separate per-environment scripts
  into a single script, to avoid duplicating the PDR-calculation logic
  (`calculerPDR_fromTable`, Wilson interval pooling) four times.
- The Underground Industrial environment's Scenario 1 / Scenario 2 mapping
  is reconstructed from filenames via an explicit lookup table inside the
  script (filenames do not carry an explicit scenario label); see the
  comment block at the top of the script and
  [`../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/README.md`](../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/README.md)
  for the full mapping.
- Outputs `Table7_PDR_with_CI.csv` in this folder, matching Table 7 of the
  manuscript exactly (Environment, Config, PDR %, 95% CI, Mean PDR %).

## Known Data Note (RSSI vs. Channel RSSI)

`RSSI_dBm` and `ChannelRSSI_dBm` are two distinct fields in the dataset:
`RSSI_dBm` is the network server's SNR-adjusted signal estimate, while
`ChannelRSSI_dBm` is the raw, uncorrected per-channel receiver reading. Some
scripts explicitly use `ChannelRSSI_dBm` (`rssi_vs_frequency.m`,
`correlation_3d.m`) to keep the plotted quantity statistically independent
of SNR; this is documented in-line in those scripts and in
[`../Dataset/By_Environment_and_Condition/README.md`](../Dataset/By_Environment_and_Condition/README.md).
