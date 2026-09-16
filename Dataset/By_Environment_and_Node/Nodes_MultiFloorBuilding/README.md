# Raw Per-Node Files — Multi-Floor Building Environment

15 files, across 5 floors — Basement/Sous-sol (SS), Ground floor (RC),
Floor 1, Floor 2, Floor 3 (see Section 3.2.3 and Table 4 of the paper).
Read by
[`../../../Experimental Results Analysis/CalculPDR.m`](../../../Experimental%20Results%20Analysis/CalculPDR.m).

```
NodeB1_SS_NLOS.csv
NodeB2_SS_NLOS.csv
NodeB3_SS_NLOS.csv
Node01_RC_NLOS.csv
Node02_RC_NLOS.csv
Node03_RC_NLOS.csv
Node11_Floor1_NLOS.csv
Node12_Floor1_NLOS.csv
Node13_Floor1_NLOS.csv
Node21_Floor2_NLOS.csv
Node22_Floor2_NLOS.csv
Node23_Floor2_NLOS.csv
Node31_Floor3_NLOS.csv
Node32_Floor3_NLOS.csv
Node33_Floor3_NLOS.csv
```

**Note on filename casing.** The three Floor 2 files were originally
supplied with a lowercase `floor2`; they are kept here as `Floor2` (capital
F) to match the exact case expected by `CalculPDR.m` — MATLAB file lookups
are case-sensitive on most systems (including the Linux environments
typically used for CI/CD or when running from GitHub), so this mismatch
would otherwise cause a file-not-found error.

All nodes in this environment were tested under NLOS only. Note that the
same physical node hardware was reused across floors during this campaign
(see Section 3.2.3 of the paper and
[`../README.md`](../README.md)): the 15 files above correspond to only 6
distinct physical devices, not 15 distinct units.

Each file contains one row per transmission attempt (17 columns, no header
names relied upon — columns are read by position; column 9 is the
transmission timestamp used for the PDR calculation), including undelivered
transmissions, so that PDR can be computed as (packets received / packets
sent).
