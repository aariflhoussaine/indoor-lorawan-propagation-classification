# Dataset

The complete raw measurement dataset (43,100 packets, four indoor
environments), provided in **two different granularities** (matching what
each piece of analysis code actually needs), plus the **Node-RED
collection pipeline** used to produce them.

```
Dataset/
├── Board_Mapping.csv               <- Device_ID -> physical board, per environment
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
  each spanning that node's complete transmission timeline. Each row is a
  received packet; the number of expected transmissions is derived from the
  node's first and last timestamps and the fixed 30-second interval, so the
  Packet Delivery Rate (received / expected) can be computed per node.
  **Used by:** `CalculPDR.m` and panel (b) of `correlation_3d.m` (multi-floor
  building, one distance per deployment), in
  [`../Experimental Results Analysis/`](../Experimental%20Results%20Analysis/).

  **The two folders are two separate recordings of the same measurement
  campaigns, not two views of one file.** The aggregate files were assembled
  from a separate export (SNR rounded to 0.1 dB), whereas the per-node
  files come from the Node-RED export of the network-server messages (full
  numerical precision). Total packet counts per environment agree to within
  one packet, but the two sources are not identical packet by packet: the
  split between LOS and NLOS conditions and the extreme RSSI/SNR values differ
  slightly. Each analysis in the paper uses one source consistently (see
  "Used by" above), and the paper states which. Do not mix the two in a
  single computation.

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

## Physical Boards and Node Labels

The same nine physical Heltec boards were used in all four environments.
Device labels are `Node1`-`Node9` in the residential environment and
`noeud1`-`noeud7` elsewhere, with `Nodek` corresponding to `noeudk`. The
physical board is therefore the digit of the label; the correspondence is given
in [`Board_Mapping.csv`](Board_Mapping.csv) (26 node deployments, 9 boards).
Because the boards were redeployed, a `Device_ID` alone does not identify a
position (multi-floor building: 15 deployments, 6 identifiers; underground
industrial: 14 deployments, 7 identifiers). Environment identity is
confounded with node placement and recording session.

Recording days (calendar days per environment): residential 3 (2025-07-01 to
07-03), laboratory 2 (07-02 to 07-03), multi-floor building 3 (07-02 to 07-04),
underground industrial 1 (07-04). Continuous operation per campaign ranged
from about 8 to 42 hours.

## Known Limitations of the Collection

* The Node-RED flow is provided for the underground industrial environment
  only; the flows of the other three environments were not archived, and the
  TTN application API key used by the MQTT broker is not part of the export.
* The per-campaign The Things Stack release, the ADR convergence, collision
  counts, ambient temperature and humidity were not recorded, and the antenna
  gain of the nodes is unspecified. No independent RF calibration was
  performed.
* Continuous operation at one packet every 30 s exceeds the fair-use guideline
  of the TTN community network (30 s of uplink airtime per device and day:
  about 135 s with SF7 and 267 s with SF8 per day), while respecting the
  regulatory 1 % duty-cycle limit (maximum observed 0.31 %).
* Only the packets received by the gateway are recorded; the PDR is computed
  within the window delimited by the first and last received packet of each
  node (see the Experimental Results Analysis README).
