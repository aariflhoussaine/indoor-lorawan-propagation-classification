# Dataset

The complete raw measurement dataset (43,100 packets, four indoor
environments), provided in **two different granularities** (matching what
each piece of analysis code actually needs), plus the **Node-RED
collection pipeline** used to produce them.

```
Dataset/
├── By_Environment_and_Condition/   <- 7 files, one per environment/condition
├── By_Environment_and_Node/        <- 50 files, one per physical node
└── Node-RED_Flows/                 <- Node-RED flow(s) used for data collection
```

## Contents

- **[`By_Environment_and_Condition/`](By_Environment_and_Condition/)**
  contains one CSV per environment and LOS/NLOS/scenario condition (7 files
  total), with all nodes for that condition merged together. This is
  sufficient for every analysis that only needs successfully received
  packets and their radio metrics — which covers all of Section 4.1's RSSI,
  SNR, frequency, and correlation analysis, and the entire machine learning
  pipeline in Section 4.2. **Used by:** the Jupyter notebook in
  [`../Machine Learning-Based Environment Classification/`](../Machine%20Learning-Based%20Environment%20Classification/),
  and every MATLAB script in
  [`../Experimental Results Analysis/`](../Experimental%20Results%20Analysis/)
  **except** `CalculPDR.m`.

- **[`By_Environment_and_Node/`](By_Environment_and_Node/)** contains one
  CSV per individual physical node (50 files across the four environments),
  each spanning that node's complete transmission timeline — including
  transmission attempts that were never received by the gateway. Computing
  a Packet Delivery Rate requires knowing the total number of attempts, not
  just the successfully received packets, which is only recoverable at this
  finer granularity. **Used by:** `CalculPDR.m` only, in
  [`../Experimental Results Analysis/`](../Experimental%20Results%20Analysis/).

  Both of the above describe the same underlying measurement campaign; they
  are simply two different aggregations of it, kept side by side so that
  each script reads only the granularity it actually needs, in the format
  it needs it in, without either script performing its own re-aggregation.

- **[`Node-RED_Flows/`](Node-RED_Flows/)** contains the Node-RED flow
  configuration(s) used to collect and format the raw data at the source —
  the MQTT-to-CSV pipeline described in Section 3.1.3 of the paper that
  produced the files in the two folders above. Currently includes the flow
  used for the Underground Industrial environment; see that folder's README
  for the full pipeline description and its current coverage of the other
  three environments.

See each subfolder's own README for the full file listing, column
descriptions, and environment-specific notes.

## Complete Dataset and Citable Reference

The dataset in this repository is the complete dataset used in the paper
(43,100 packets) and is publicly available at this GitHub repository.

## Collection Methodology (Summary)

See Sections 3.1–3.3 of the paper for full details. In summary: Heltec WiFi
LoRa 32 V3.2 nodes transmitted uplinks every 30 seconds with Adaptive Data
Rate (ADR) enabled, received by an LPS8v2 gateway (SX1308 concentrator) and
routed via The Things Network (TTN) and Node-RED to CSV. All measurements
were collected in Casablanca, Morocco, in the EU868 frequency band.

**Important methodological note.** ADR was enabled throughout data
collection, meaning spreading factor and transmission power were
dynamically adjusted based on link quality. Reported RSSI/SNR/PDR
statistics therefore reflect network-adapted behavior rather than a
fixed-parameter propagation characterization. See the paper's Discussion
(Section 5) for further detail.
