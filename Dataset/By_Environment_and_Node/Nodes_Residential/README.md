# Raw Per-Node Files — Residential Environment

13 files, covering 9 physical nodes (Nodes 1–4 have both LOS and NLOS
files; Nodes 5–9 were only tested under NLOS, see Section 3.2.1 of the
paper). Read by
[`../../../Experimental Results Analysis/CalculPDR.m`](../../../Experimental%20Results%20Analysis/CalculPDR.m).

```
Node1_LOS_2m.csv
Node1_NLOS_4m.csv
Node2_LOS_4m.csv
Node2_NLOS_6m.csv
Node3_LOS_5m.csv
Node3_NLOS_3.6m.csv
Node4_LOS_3.6m.csv
Node4_NLOS_2m.csv
Node5_NLOS_6m.csv
Node6_NLOS_4m.csv
Node7_NLOS_5.7m.csv
Node8_NLOS_8.5m.csv
Node9_NLOS_6.7m.csv
```

**Note on filename distances vs. Table 2.** The distances encoded in the
filenames above (e.g. `Node2_NLOS_6m.csv`) do not numerically match the
distances published in Table 2 of the manuscript for four nodes (Node2,
Node4, Node6, Node7). Table 2 reflects the final, confirmed measurements
reported in the paper and has not been changed. The filenames are
historical internal labels from the data collection process and should not
be read as an updated or corrected distance — they are kept as originally
assigned so the raw files remain traceable to their original export, but
Table 2 remains the authoritative reference for node distances.

Each file contains one row per transmission attempt (17 columns, no header
names relied upon — columns are read by position; column 9 is the
transmission timestamp used for the PDR calculation), including undelivered
transmissions, so that PDR can be computed as (packets received / packets
sent).
