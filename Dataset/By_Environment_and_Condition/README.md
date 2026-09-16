# By Environment and Condition

Seven CSV files, one per indoor environment and LOS/NLOS/scenario condition,
covering the complete dataset of **43,100 packets** reported in the paper
(Table 6). Each file contains only successfully received packets, with all
nodes for that environment/condition merged together into a single file.

## Files and Environment Mapping

Files are named `<Environment>_<Condition>.csv`, matching the environment
classes used throughout the paper (Section 3.2) and the class distribution
in Table 6.

| File | Environment (paper §3.2) | Condition | Packets |
|---|---|---|---|
| `Residential_LOS.csv` | Residential (apartment) | Line-of-sight | 3,181 |
| `Residential_NLOS.csv` | Residential (apartment) | Non-line-of-sight | 5,819 |
| `Laboratory_LOS.csv` | Research Laboratory | Line-of-sight | 4,364 |
| `Laboratory_NLOS.csv` | Research Laboratory | Non-line-of-sight | 4,236 |
| `MultiFloorBuilding_NLOS.csv` | Multi-floor building (EMSI, 5 floors) | Non-line-of-sight (only condition tested) | 12,500 |
| `UndergroundIndustrial_Scenario1.csv` | Underground Industrial (pilot plant) | Scenario 1 | 6,685 |
| `UndergroundIndustrial_Scenario2.csv` | Underground Industrial (pilot plant) | Scenario 2 | 6,315 |
| **Total** | | | **43,100** |

**Note on the four ML classes.** For the supervised classification pipeline
described in Section 4.2 of the paper, files are aggregated as follows:

- **Residential** = `Residential_LOS.csv` + `Residential_NLOS.csv`
- **Laboratory** = `Laboratory_LOS.csv` + `Laboratory_NLOS.csv`
- **Multi-floor building** = `MultiFloorBuilding_NLOS.csv`
- **Underground Industrial** = `UndergroundIndustrial_Scenario1.csv` + `UndergroundIndustrial_Scenario2.csv`

**Note on device naming.** Node identifiers are inconsistently labeled across
campaigns (`Node1`, `Node2`, ... in the Residential files vs. `noeud1`,
`noeud2`, ... elsewhere, French for "node"). This reflects the original data
collection scripts and does not affect data validity; identifiers are unique
only *within* each file, not necessarily across files (see
[`../By_Environment_and_Node/README.md`](../By_Environment_and_Node/README.md)
for how physical node identity is reconciled across environments for the
group-aware validation in Section 4.2.4 of the paper).

## Column Description

All files share the same 17-column structure (semicolon-delimited, `;`),
except the two Underground Industrial files, which include one additional
column (`Conditions_1`).

| Column | Description | Unit / Format |
|---|---|---|
| `DR_Time` | Uplink reception timestamp (Unix epoch) | seconds (float) |
| `Device_ID` | LoRa node identifier | string |
| `Gateway_ID` | LPS8v2 gateway EUI | hex string |
| `FPort` | LoRaWAN application port | integer |
| `Payload_hex` | Raw uplink payload | hex-encoded string |
| `Bandwidth_kHz` | LoRa channel bandwidth | kHz |
| `SpreadingFactor_SF` | LoRa spreading factor (set by ADR) | integer (SF7–SF8 observed throughout this campaign) |
| `CodingRate` | Forward error correction coding rate | string (see data quirk note below) |
| `Frequency_Hz` | Channel center frequency | Hz |
| `DR_Timestamp` | Network server timestamp | integer |
| `Airtime_s` | Time-on-air of the packet | seconds (string, e.g. `"0.046336s"`) |
| `RSSI_dBm` | Received Signal Strength Indicator, SNR-adjusted by the network server | dBm |
| `ChannelRSSI_dBm` | Raw, uncorrected per-channel RSSI reading | dBm |
| `SNR_dB` | Signal-to-Noise Ratio | dB |
| `FrequencyOffset_Hz` | Measured carrier frequency offset | Hz |
| `ChannelIndex` | Gateway demodulation channel index | integer (may contain `NaN`) |
| `QoS` | Quality-of-service indicator flag | integer/binary |
| `Conditions_1` *(Underground files only)* | LOS/NLOS condition per node | string (`"LOS"` / `"NLOS"`) |

**RSSI_dBm vs. ChannelRSSI_dBm.** These are two distinct, non-redundant
quantities. `RSSI_dBm` is adjusted by the LoRaWAN network server according
to the standard convention that corrects for SNR (a correction is applied
when SNR is negative, since LoRa can demodulate below the noise floor).
`ChannelRSSI_dBm` is the raw, uncorrected receiver measurement on the
physical channel. The paper uses `RSSI_dBm` for the general RSSI
distribution (Figure 10) and `ChannelRSSI_dBm` where independence from the
SNR-based correction matters (Figures 11 and 13).

**Known data quirk — `CodingRate` column.** Values appear as
spreadsheet-locale date strings (e.g., `04-mai`, French for "4-May") instead
of the expected coding-rate notation (e.g., `4/5`). This is an artifact of
the original CSV having been opened and re-saved in a spreadsheet
application with automatic date conversion enabled on a French locale.
**Coding rate was fixed at 4/5 for all measurements** (the standard default
for LoRaWAN); disregard the literal string in this column.

## Regulatory Compliance

The 30-second transmission interval was verified against the EU868
duty-cycle limit of 1% per channel: packets across the complete dataset used
spreading factors SF7 and SF8 only, corresponding to airtimes of 46.7 ms and
92.7 ms respectively, with a maximum observed duty-cycle usage of 0.31% —
well within the regulatory budget. Frequency hopping followed the standard
TTN EU868 8-channel plan (867.1–868.5 MHz).
