# Raw Per-Node Files — Underground Industrial Environment

14 files, across Scenario 1 and Scenario 2 (see Section 3.2.4 and Table 5
of the paper). Read by
[`../../../Experimental Results Analysis/CalculPDR.m`](../../../Experimental%20Results%20Analysis/CalculPDR.m).

```
Node1_UP_LOS.csv
Node2_UP_LOS.csv
Node3_UP_LOS.csv
Node4_UP_NLOS.csv
Node5_BTUP_NLOS.csv
Node6_LAIUP_NLOS.csv
Node7_LEPEUP_NLOS.csv
Node1_UP_NLOS.csv
Node2_UP_NLOS.csv
Node3_UP_NLOS.csv
Node4_LI7UP_NLOS.csv
Node5_LCSE1UP_NLOS.csv
Node6_LCSE2UP_NLOS.csv
Node7_LI3UP_NLOS.csv
```

**Scenario mapping.** Filenames do not carry an explicit "Scenario1" /
"Scenario2" label; the mapping below is reconstructed from the paper's
description of each scenario and is hard-coded as an explicit lookup table
inside `CalculPDR.m`:

- Plain `UP_LOS` / `UP_NLOS` filenames (the first 7 files above) correspond
  to **Scenario 2**.
- Location-coded filenames — `BT`, `LAI`, `LEPE`, `LI7`, `LCSE1`, `LCSE2`,
  `LI3` (the last 7 files above) — correspond to **Scenario 1**.

Note that the same physical node hardware was reused across the two
scenarios (see Section 3.2.4 of the paper): the 14 files above correspond
to only 7 distinct physical devices.

**Row-count note.** `Node6_LAIUP_NLOS.csv` contains noticeably fewer
transmission-attempt rows than the other files in this folder (roughly a
quarter of the typical count), consistent with a shorter measurement
session for this particular node/position rather than a data error; PDR is
computed the same way regardless (received / expected, from the node's own
timestamp span).

Each file contains one row per transmission attempt (17 columns, no header
names relied upon — columns are read by position; column 9 is the
transmission timestamp used for the PDR calculation), including undelivered
transmissions, so that PDR can be computed as (packets received / packets
sent).
