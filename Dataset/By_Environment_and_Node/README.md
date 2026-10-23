# By Environment and Node

Raw per-node CSV files, organized in one subfolder per environment, used
for the Packet Delivery Rate (PDR) calculation (Table 7 of the paper) and for
panel (b) of Fig. 13 (multi-floor building, one distance per deployment). Unlike the aggregate files in
[`../By_Environment_and_Condition/`](../By_Environment_and_Condition/), each
file here covers **the complete transmission timeline of one physical
node**. Every row is a packet that was received; the number of expected
transmissions is computed from the first and last timestamps and the fixed
30-second interval, which is what the PDR calculation requires. These files
come from the Node-RED export of the network-server messages and are a
separate recording from the aggregate files (assembled from the gateway-side
logs): the two agree on total packet counts per environment but not packet
by packet.

## Structure

```
By_Environment_and_Node/
├── Nodes_Residential/            (13 files,  9 physical nodes)
├── Nodes_Laboratory/             ( 8 files,  4 physical nodes)
├── Nodes_MultiFloorBuilding/     (15 files,  6 physical nodes -- see note below)
└── Nodes_UndergroundIndustrial/  (14 files,  7 physical nodes -- see note below)
```

Total: 50 files, 26 distinct physical nodes across the four environments
(9 + 4 + 6 + 7 = 26), matching the node count used in the group-aware,
node-level cross-validation described in Section 4.2.4 of the paper.

Each subfolder has its own README with the exact file listing and any
environment-specific naming or mapping notes. All four subfolders are read
by a single script:

| Script | Location |
|---|---|
| `CalculPDR.m` | [`../../Experimental Results Analysis/CalculPDR.m`](../../Experimental%20Results%20Analysis/CalculPDR.m) |

## Column Format

Each file has the same 17-column structure as the aggregate files in
`By_Environment_and_Condition/` (see that folder's README for the full
column dictionary), with no header row relied upon by the reading script —
columns are read by position. Column 9 is the transmission timestamp used
to compute the expected number of transmissions (from the fixed 30-second
interval) against the number of rows actually present in the file (received
packets), giving PDR = received / expected for that node.

## Note on Physical Node Reuse (Multi-floor and Underground)

In the Multi-floor building and Underground Industrial environments, the
same physical node hardware was redeployed across floors or scenarios
during the measurement campaign. This means the number of raw files is
higher than the number of distinct physical devices:

- **Multi-floor building:** 15 files correspond to only **6** distinct
  physical node identifiers (device IDs `noeud1`–`noeud6`), each redeployed
  across the 5 floors of the building.
- **Underground Industrial:** 14 files correspond to only **7** distinct
  physical node identifiers (device IDs `noeud1`–`noeud7`), each redeployed
  across the two scenarios.

This is documented explicitly in Sections 3.2.3 and 3.2.4 of the paper and
is accounted for in the node-group identifier used for group-aware
cross-validation in Section 4.2.4 (grouping is by environment + device ID,
not by filename).
