% === Script: correlation_3d_all.m ===
% Reproduces Figure 13 of the paper as a SINGLE figure with four subplots:
% SNR-RSSI-Distance scatter plots for the four measurement environments.
%
%   (a) Residential            - LOS + NLOS, distances from Table 2
%   (b) Multi-floor building   - NLOS only,  distances from Table 4
%   (c) Research Laboratory    - LOS + NLOS, distances from Table 3
%   (d) Underground Industrial - Scenario 1 + Scenario 2, distances from Table 5
%
% Each panel is produced by its own local function (defined at the bottom
% of this file) so that variable names (data, rssi, snr, dist, ...) do not
% clash between panels. The main script below creates one figure with a
% 2x2 tiled layout and calls each function into its own tile.
%
% DATA EXPORT: each panel function now also returns a table with the
% exact (SNR, RSSI, Distance) triplets it plotted (one row per point,
% valid rows only). Each panel's table is written to its own CSV, and all
% four are also concatenated into one combined CSV covering the whole
% figure.

clear;
clc;
close all;

DATA_DIR = '../Dataset/By_Environment_and_Condition/';
OUTPUT_DIR = '.';  % where the exported CSV tables are written

fig = figure('Color', 'w', 'Position', [100 100 1200 900]);
tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
T_residential = plot_residential(DATA_DIR);
title('(a) Residential environment', 'FontWeight', 'bold');

nexttile;
T_multifloor = plot_multifloor(DATA_DIR);
title('(b) Multi-floor building (NLOS)', 'FontWeight', 'bold');

nexttile;
T_laboratory = plot_laboratory(DATA_DIR);
title('(c) Research Laboratory', 'FontWeight', 'bold');

nexttile;
T_underground = plot_underground(DATA_DIR);
title('(d) Underground industrial', 'FontWeight', 'bold');

%sgtitle('SNR - RSSI - Distance correlation across environments', 'FontWeight', 'bold');

% === Export: per-panel CSVs + one combined CSV ===
writetable(T_residential, fullfile(OUTPUT_DIR, 'correlation_3d_data_residential.csv'));
writetable(T_multifloor,  fullfile(OUTPUT_DIR, 'correlation_3d_data_multifloor.csv'));
writetable(T_laboratory,  fullfile(OUTPUT_DIR, 'correlation_3d_data_laboratory.csv'));
writetable(T_underground, fullfile(OUTPUT_DIR, 'correlation_3d_data_underground.csv'));

T_all = [T_residential; T_multifloor; T_laboratory; T_underground];
writetable(T_all, fullfile(OUTPUT_DIR, 'correlation_3d_data_all.csv'));


% ============================================================
% Local functions (one per environment / subplot)
% Each function plots into the CURRENT axes (the tile selected by
% nexttile in the main script above) instead of creating its own figure,
% and returns a table of the exact values it plotted.
% ============================================================

function T = plot_residential(DATA_DIR)
% Panel (a): Residential environment (LOS + NLOS), distances from Table 2.

    % Distance lookup table (Table 2 of the paper, in meters)
    distLOS = containers.Map(...
        {'Node1','Node2','Node3','Node4'}, ...
        {2, 4, 5, 3.6});

    distNLOS = containers.Map(...
        {'Node1','Node2','Node3','Node4','Node5','Node6','Node7','Node8','Node9'}, ...
        {4, 7.2, 3.6, 4, 6, 7.2, 5.6, 8.5, 6.7});

    % NOTE: LOS and NLOS have different distances for shared Device_IDs
    % (e.g. Node1 = 2m in LOS but 4m in NLOS), so each condition is plotted
    % with its own map, as two scatter3 calls on the same axes.

    hold on;

    % --- LOS ---
    dataLOS = readtable(fullfile(DATA_DIR, 'Residential_LOS.csv'), 'Delimiter', ';');
    idLOS = string(dataLOS{:,2});
    rssiLOS = dataLOS{:,13}; % ChannelRSSI_dBm; see ../README.md for the RSSI vs ChannelRSSI distinction
    snrLOS = dataLOS{:,14};
    distValsLOS = nan(height(dataLOS),1);
    for k = 1:height(dataLOS)
        if isKey(distLOS, idLOS(k)); distValsLOS(k) = distLOS(idLOS(k)); end
    end
    validLOS = ~isnan(rssiLOS) & ~isnan(snrLOS) & ~isnan(distValsLOS);
    h1 = scatter3(snrLOS(validLOS), rssiLOS(validLOS), distValsLOS(validLOS), ...
        36, [0 0.4470 0.7410], 'o', 'filled', 'MarkerFaceAlpha', 0.7);

    % --- NLOS ---
    dataNLOS = readtable(fullfile(DATA_DIR, 'Residential_NLOS.csv'), 'Delimiter', ';');
    idNLOS = string(dataNLOS{:,2});
    rssiNLOS = dataNLOS{:,13};
    snrNLOS = dataNLOS{:,14};
    distValsNLOS = nan(height(dataNLOS),1);
    for k = 1:height(dataNLOS)
        if isKey(distNLOS, idNLOS(k)); distValsNLOS(k) = distNLOS(idNLOS(k)); end
    end
    validNLOS = ~isnan(rssiNLOS) & ~isnan(snrNLOS) & ~isnan(distValsNLOS);
    h2 = scatter3(snrNLOS(validNLOS), rssiNLOS(validNLOS), distValsNLOS(validNLOS), ...
        36, [0.8500 0.3250 0.0980], 's', 'filled', 'MarkerFaceAlpha', 0.7);

    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11);  % plotted value is ChannelRSSI_dBm
    zlabel('Distance (m)', 'FontSize', 11);
    legend([h1 h2], {'LOS', 'NLOS'}, 'Location', 'best');
    grid on;
    view(45, 25);
    hold off;

    % --- Export table: the exact points plotted above ---
    Environment = repmat("Residential", sum(validLOS)+sum(validNLOS), 1);
    Condition = [repmat("LOS", sum(validLOS), 1); repmat("NLOS", sum(validNLOS), 1)];
    DeviceID = [idLOS(validLOS); idNLOS(validNLOS)];
    SNR_dB = [snrLOS(validLOS); snrNLOS(validNLOS)];
    RSSI_dBm = [rssiLOS(validLOS); rssiNLOS(validNLOS)];
    Distance_m = [distValsLOS(validLOS); distValsNLOS(validNLOS)];
    T = table(Environment, Condition, DeviceID, SNR_dB, RSSI_dBm, Distance_m);
end


function T = plot_laboratory(DATA_DIR)
% Panel (c): Research Laboratory environment (LOS + NLOS), using distances
% from Table 3 (one distance per node, valid for both LOS and NLOS).

    % --- Table 3 distances (meters) ---
    DEVICE_TO_DISTANCE = containers.Map( ...
        {'noeud1', 'noeud2', 'noeud3', 'noeud4'}, ...
        {10,        12,        8,         11.2});

    % ------------------------------------------------------------
    % Read LOS and NLOS datasets
    % ------------------------------------------------------------

    dataLOS = readtable( ...
        fullfile(DATA_DIR, 'Laboratory_LOS.csv'), ...
        'Delimiter', ';');

    dataNLOS = readtable( ...
        fullfile(DATA_DIR, 'Laboratory_NLOS.csv'), ...
        'Delimiter', ';');

    % ------------------------------------------------------------
    % Extract data
    % ------------------------------------------------------------

    % Column 2 = Device_ID
    deviceIDs_LOS = string(dataLOS{:,2});
    deviceIDs_NLOS = string(dataNLOS{:,2});

    % Column 13 = ChannelRSSI_dBm
    rssi_LOS = dataLOS{:,13};
    rssi_NLOS = dataNLOS{:,13};

    % Column 14 = SNR
    snr_LOS = dataLOS{:,14};
    snr_NLOS = dataNLOS{:,14};

    % ------------------------------------------------------------
    % Assign distances
    % ------------------------------------------------------------

    dist_LOS = nan(height(dataLOS), 1);
    dist_NLOS = nan(height(dataNLOS), 1);

    for k = 1:height(dataLOS)
        key = deviceIDs_LOS(k);
        if isKey(DEVICE_TO_DISTANCE, key)
            dist_LOS(k) = DEVICE_TO_DISTANCE(key);
        end
    end

    for k = 1:height(dataNLOS)
        key = deviceIDs_NLOS(k);
        if isKey(DEVICE_TO_DISTANCE, key)
            dist_NLOS(k) = DEVICE_TO_DISTANCE(key);
        end
    end

    % ------------------------------------------------------------
    % Select valid samples
    % ------------------------------------------------------------

    valid_LOS = ...
        ~isnan(rssi_LOS) & ...
        ~isnan(snr_LOS) & ...
        ~isnan(dist_LOS);

    valid_NLOS = ...
        ~isnan(rssi_NLOS) & ...
        ~isnan(snr_NLOS) & ...
        ~isnan(dist_NLOS);

    % ------------------------------------------------------------
    % Report number of valid samples
    % ------------------------------------------------------------

    fprintf('[Laboratory] LOS valid samples  : %d\n', sum(valid_LOS));
    fprintf('[Laboratory] NLOS valid samples : %d\n', sum(valid_NLOS));

    % ------------------------------------------------------------
    % 3D scatter plot
    % ------------------------------------------------------------

    hold on;

    scatter3( ...
        snr_LOS(valid_LOS), ...
        rssi_LOS(valid_LOS), ...
        dist_LOS(valid_LOS), ...
        36, ...
        dist_LOS(valid_LOS), ...
        'filled');

    scatter3( ...
        snr_NLOS(valid_NLOS), ...
        rssi_NLOS(valid_NLOS), ...
        dist_NLOS(valid_NLOS), ...
        36, ...
        dist_NLOS(valid_NLOS), ...
        'filled');

    % ------------------------------------------------------------
    % Labels
    % ------------------------------------------------------------

    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11);
    zlabel('Distance (m)', 'FontSize', 11);

    grid on;
    view(45, 25);

    colorbar;

    legend( ...
        'LOS', ...
        'NLOS', ...
        'Location', 'best');

    hold off;

    % --- Export table: the exact points plotted above ---
    Environment = repmat("Laboratory", sum(valid_LOS)+sum(valid_NLOS), 1);
    Condition = [repmat("LOS", sum(valid_LOS), 1); repmat("NLOS", sum(valid_NLOS), 1)];
    DeviceID = [deviceIDs_LOS(valid_LOS); deviceIDs_NLOS(valid_NLOS)];
    SNR_dB = [snr_LOS(valid_LOS); snr_NLOS(valid_NLOS)];
    RSSI_dBm = [rssi_LOS(valid_LOS); rssi_NLOS(valid_NLOS)];
    Distance_m = [dist_LOS(valid_LOS); dist_NLOS(valid_NLOS)];
    T = table(Environment, Condition, DeviceID, SNR_dB, RSSI_dBm, Distance_m);
end


function T = plot_multifloor(DATA_DIR)
% Panel (b): Multi-floor building environment (NLOS only), using distances
% from Table 4.
%
% Table 4 reports distances by floor and position label (Basement/Ground/
% First/Second/Third floor, each with Position 1/2/3), while the merged
% dataset (../data/MultiFloorBuilding_NLOS.csv) identifies nodes by a
% generic Device_ID ('noeud1'...'noeud6' in this sample; up to 15 in the
% full dataset). DEVICE_TO_DISTANCE below maps each Device_ID to its
% corresponding distance and should be kept in sync with the actual
% floor/position assignment of each node.

    % --- Table 4 distances (meters), for reference ---
    % Basement:      B1=28,   B2=45.3, B3=48.2
    % Ground floor:  O1=27,   O2=44.7, O3=47.6
    % First floor:   F1=26.4, F2=44.3, F3=47.3
    % Second floor:  S1=26,   S2=44,   S3=47
    % Third floor:   T1=26.2, T2=44.1, T3=47.1

    DEVICE_TO_DISTANCE = containers.Map( ...
        {'noeud1', 'noeud2', 'noeud3', 'noeud4', 'noeud5', 'noeud6'}, ...
        {28,        45.3,     48.2,     27,       44.7,     47.6});
    % Extend this map with the remaining Table 4 values (26.4, 44.3, 47.3, 26,
    % 44, 47, 26.2, 44.1, 47.1) for datasets with more than 6 nodes.

    data = readtable(fullfile(DATA_DIR, 'MultiFloorBuilding_NLOS.csv'), 'Delimiter', ';');
    deviceIDs = string(data{:,2});
    rssi = data{:,13}; % ChannelRSSI_dBm
    snr = data{:,14};

    dist = nan(height(data), 1);
    for k = 1:height(data)
        key = deviceIDs(k);
        if isKey(DEVICE_TO_DISTANCE, key)
            dist(k) = DEVICE_TO_DISTANCE(key);
        end
    end

    valid = ~isnan(rssi) & ~isnan(snr) & ~isnan(dist);
    nSkipped = sum(~valid & ~isnan(rssi) & ~isnan(snr));
    if nSkipped > 0
        warning('[Multi-floor] %d rows skipped: Device_ID not found in DEVICE_TO_DISTANCE map.', nSkipped);
    end

    scatter3(snr(valid), rssi(valid), dist(valid), 36, dist(valid), 'filled');
    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11); % plotted value is ChannelRSSI_dBm
    zlabel('Distance (m)', 'FontSize', 11);
    grid on;
    view(45, 25);
    colorbar;

    % --- Export table: the exact points plotted above ---
    Environment = repmat("MultiFloorBuilding", sum(valid), 1);
    Condition = repmat("NLOS", sum(valid), 1);
    DeviceID = deviceIDs(valid);
    SNR_dB = snr(valid);
    RSSI_dBm = rssi(valid);
    Distance_m = dist(valid);
    T = table(Environment, Condition, DeviceID, SNR_dB, RSSI_dBm, Distance_m);
end


function T = plot_underground(DATA_DIR)
% Panel (d): Underground Industrial environment (Scenario 1 + Scenario 2),
% using distances from Table 5. Node IDs repeat across scenarios with
% DIFFERENT distances (e.g. noeud1 = 4.2m in Scenario 1 but 5m in Scenario
% 2), so each scenario is plotted with its own map, as in plot_residential
% above.

    distScenario1 = containers.Map(...
        {'noeud1','noeud2','noeud3','noeud4','noeud5','noeud6','noeud7'}, ...
        {4.2, 8, 10.7, 13, 20, 32, 25});

    distScenario2 = containers.Map(...
        {'noeud1','noeud2','noeud3','noeud4','noeud5','noeud6','noeud7'}, ...
        {5, 8, 6.4, 8.9, 23, 40, 22});

    hold on;

    % --- Scenario 1 ---
    data1 = readtable(fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario1.csv'), 'Delimiter', ';');
    id1 = string(data1{:,2});
    rssi1 = data1{:,13}; % ChannelRSSI_dBm; see ../README.md for the RSSI vs ChannelRSSI distinction
    snr1 = data1{:,14};
    dist1 = nan(height(data1),1);
    for k = 1:height(data1)
        if isKey(distScenario1, id1(k)); dist1(k) = distScenario1(id1(k)); end
    end
    valid1 = ~isnan(rssi1) & ~isnan(snr1) & ~isnan(dist1);
    h1 = scatter3(snr1(valid1), rssi1(valid1), dist1(valid1), ...
        36, [0 0.4470 0.7410], 'o', 'filled', 'MarkerFaceAlpha', 0.7);

    % --- Scenario 2 ---
    data2 = readtable(fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario2.csv'), 'Delimiter', ';');
    id2 = string(data2{:,2});
    rssi2 = data2{:,13};
    snr2 = data2{:,14};
    dist2 = nan(height(data2),1);
    for k = 1:height(data2)
        if isKey(distScenario2, id2(k)); dist2(k) = distScenario2(id2(k)); end
    end
    valid2 = ~isnan(rssi2) & ~isnan(snr2) & ~isnan(dist2);
    h2 = scatter3(snr2(valid2), rssi2(valid2), dist2(valid2), ...
        36, [0.4940 0.1840 0.5560], 's', 'filled', 'MarkerFaceAlpha', 0.7);

    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11); % plotted value is ChannelRSSI_dBm
    zlabel('Distance (m)', 'FontSize', 11);
    legend([h1 h2], {'Scenario 1', 'Scenario 2'}, 'Location', 'best');
    grid on;
    view(45, 25);
    hold off;

    % --- Export table: the exact points plotted above ---
    Environment = repmat("UndergroundIndustrial", sum(valid1)+sum(valid2), 1);
    Condition = [repmat("Scenario 1", sum(valid1), 1); repmat("Scenario 2", sum(valid2), 1)];
    DeviceID = [id1(valid1); id2(valid2)];
    SNR_dB = [snr1(valid1); snr2(valid2)];
    RSSI_dBm = [rssi1(valid1); rssi2(valid2)];
    Distance_m = [dist1(valid1); dist2(valid2)];
    T = table(Environment, Condition, DeviceID, SNR_dB, RSSI_dBm, Distance_m);
end
