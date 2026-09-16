# Node-RED Flows

Node-RED flow configurations used during data collection, exported directly
from the Node-RED editor (`Menu → Export → Clipboard/File`, full flow). These
are the flows referenced in Section 3.1.3 of the paper ("The data received is
then processed in real time by the Node-RED platform, which filters, decodes
and structures it before automatically exporting it to a CSV file").

## `nodered_flow_underground_industrial.json`

The flow used to collect the **Underground Industrial** environment dataset
(Section 3.2.4 of the paper; CSV outputs in
[`../By_Environment_and_Node/Nodes_UndergroundIndustrial/`](../By_Environment_and_Node/Nodes_UndergroundIndustrial/)
and the aggregate
[`../By_Environment_and_Condition/UndergroundIndustrial_Scenario1.csv`](../By_Environment_and_Condition/UndergroundIndustrial_Scenario1.csv) /
[`UndergroundIndustrial_Scenario2.csv`](../By_Environment_and_Condition/UndergroundIndustrial_Scenario2.csv)).

**Structure.** One MQTT broker node connects to The Things Network's EU1
endpoint (`eu1.cloud.thethings.network:1883`), feeding **seven parallel
pipelines**, one per physical node (`noeud1`–`noeud7`):

```
[mqtt in: v3/.../devices/noeudN/up] -> [function: parse + format] -> [file: append to CSV]
```

- **`mqtt in`** — subscribes to the uplink topic for one node
  (`v3/datacollect@ttn/devices/noeudN/up`), receiving the raw JSON uplink
  message published by TTN each time that node's packet is received by the
  gateway.
- **`function`** — parses the TTN uplink JSON (`uplink_message`, `settings`,
  `rx_metadata`) and reformats it into the 17-field, semicolon-delimited row
  used throughout this dataset (`device_id`, `f_port`, `frm_payload`,
  `bandwidth`, `spreading_factor`, `coding_rate`, `frequency`,
  `dr_timestamp`, `dr_time`, `airtime`, `gw_id`, `rssi`, `channel_rssi`,
  `snr`, `frequency_offset`, `channel_index`, `qos`), writing a header row
  once per session.
- **`file`** — appends each formatted row to that node's dedicated CSV file
  (e.g. `Node1_UP_NLOS.csv`, `Node6_LAIUP_NLOS.csv`).

**Note.** The exported flow's file-node paths and per-node output filenames
reflect the state of the flow at the time of the last edit; node output
targets were repointed between the two measurement scenarios described in
Section 3.2.4 of the paper (see
[`../By_Environment_and_Node/Nodes_UndergroundIndustrial/README.md`](../By_Environment_and_Node/Nodes_UndergroundIndustrial/README.md)
for the reconstructed Scenario 1 / Scenario 2 mapping), so this single
exported file represents the flow's structure and per-field parsing logic
rather than a literal record of which scenario was being collected at every
moment.

**Importing this flow.** In the Node-RED editor: `Menu → Import`, paste or
select this file, then update each `file` node's output path to a location
on your own machine before deploying — the paths saved in this export point
to the original data-collection machine and will not exist elsewhere.

## Flows for Other Environments

Node-RED flow exports for the Residential, Laboratory, and Multi-floor
building environments are not currently included in this repository. The
underlying per-field parsing logic is identical across all four
environments (see the `function` node code above), differing only in the
MQTT topics subscribed to and the output file paths.
