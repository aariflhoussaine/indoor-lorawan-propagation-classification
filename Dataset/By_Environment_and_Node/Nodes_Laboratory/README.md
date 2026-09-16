# Raw Per-Node Files — Research Laboratory Environment

8 files, covering 4 physical nodes (Nodes 1–4, each with a LOS and an NLOS
file, see Section 3.2.2 and Table 3 of the paper). Read by
[`../../../Experimental Results Analysis/CalculPDR.m`](../../../Experimental%20Results%20Analysis/CalculPDR.m).

```
Node1_Labo_LOS.csv
Node1_Labo_NLOS.csv
Node2_Labo_LOS.csv
Node2_Labo_NLOS.csv
Node3_Labo_LOS.csv
Node3_Labo_NLOS.csv
Node4_Labo_LOS.csv
Node4_Labo_NLOS.csv
```

Reference distances (Table 3 of the paper, in meters — same distance for
both LOS and NLOS):

| Node | Distance |
|---|---|
| Node1 | 10 |
| Node2 | 12 |
| Node3 | 8 |
| Node4 | 11.2 |

Each file contains one row per transmission attempt (17 columns, no header
names relied upon — columns are read by position; column 9 is the
transmission timestamp used for the PDR calculation), including undelivered
transmissions, so that PDR can be computed as (packets received / packets
sent).
