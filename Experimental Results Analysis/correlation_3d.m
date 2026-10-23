% === Script: correlation_3d_all.m ===
% Reproduces Figure 13 of the paper as a SINGLE figure with four subplots:
% SNR-RSSI-Distance scatter plots for the four measurement environments.
%
%   (a) Residential            - LOS + NLOS, distances from Table 2
%   (b) Multi-floor building   - NLOS only,  distances from Table 4, one distance
%                                per DEPLOYMENT (read from the per-node files)
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
NODE_DIR = '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/';  % panel (b) only
OUTPUT_DIR = '.';  % where the exported CSV tables are written

fig = figure('Color', 'w', 'Position', [100 100 1200 900]);
tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
T_residential = plot_residential(DATA_DIR);
title('(a) Residential environment', 'FontWeight', 'bold');

nexttile;
T_multifloor = plot_multifloor(NODE_DIR);
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

% === Spearman rank correlations (Table "Spearman" of the paper) ===
% RSSI (ChannelRSSI_dBm) and SNR versus distance, one row per
% environment x condition, computed on exactly the points plotted above.
% n = packets with valid RSSI, SNR and distance.
envList  = strings(0,1);
condList = strings(0,1);
n_pts = zeros(0,1);
rho_rssi = zeros(0,1);
rho_snr = zeros(0,1);
envs = unique(string(T_all.Environment), 'stable');
for e = 1:numel(envs)
    inEnv = string(T_all.Environment) == envs(e);
    conds = unique(string(T_all.Condition(inEnv)), 'stable');
    for c = 1:numel(conds)
        m = inEnv & string(T_all.Condition) == conds(c);
        envList(end+1,1)  = envs(e);                                          %#ok<AGROW>
        condList(end+1,1) = conds(c);                                         %#ok<AGROW>
        n_pts(end+1,1)    = sum(m);                                           %#ok<AGROW>
        rho_rssi(end+1,1) = spearman_rho(T_all.RSSI_dBm(m), T_all.Distance_m(m)); %#ok<AGROW>
        rho_snr(end+1,1)  = spearman_rho(T_all.SNR_dB(m),   T_all.Distance_m(m)); %#ok<AGROW>
    end
end
Spearman_table = table(envList, condList, n_pts, round(rho_rssi,2), round(rho_snr,2), ...
    'VariableNames', {'Environment','Condition','n','rho_RSSI_distance','rho_SNR_distance'});
disp(Spearman_table);
writetable(Spearman_table, fullfile(OUTPUT_DIR, 'correlation_spearman.csv'));


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
        'o', 'filled');

    scatter3( ...
        snr_NLOS(valid_NLOS), ...
        rssi_NLOS(valid_NLOS), ...
        dist_NLOS(valid_NLOS), ...
        36, ...
        dist_NLOS(valid_NLOS), ...
        's', 'filled');

    % ------------------------------------------------------------
    % Labels
    % ------------------------------------------------------------

    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11);
    zlabel('Distance (m)', 'FontSize', 11);

    grid on;
    view(45, 25);

    cb = colorbar;
    cb.Label.String = 'Distance (m)';

    % Colour encodes distance here, so LOS/NLOS are told apart by marker
    % shape; the legend uses neutral grey proxies (no colour meaning).
    hL = scatter3(NaN, NaN, NaN, 36, [0.4 0.4 0.4], 'o', 'filled');
    hN = scatter3(NaN, NaN, NaN, 36, [0.4 0.4 0.4], 's', 'filled');
    legend([hL hN], {'LOS', 'NLOS'}, 'Location', 'best');

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


function T = plot_multifloor(NODE_DIR)
% Panel (b): Multi-floor building environment (NLOS only), using the
% distances of Table 4.
%
% Table 4 gives one distance per DEPLOYMENT (floor + position), and the
% same physical hardware was reused across floors (15 deployments, only 6
% distinct Device_IDs), so a Device_ID alone does not identify a distance.
% The merged file MultiFloorBuilding_NLOS.csv has no floor/position column,
% so this panel reads the 15 per-node files, each of which is one
% deployment, and assigns the Table 4 distance of that deployment to every
% packet in the file.
%
% The per-node files have no header row: columns are read by position
% (1 = Device_ID, 13 = ChannelRSSI_dBm, 14 = SNR_dB).

    % --- Table 4: file -> node label -> distance (meters) ---
    files = {'NodeB1_SS_NLOS.csv',     'NodeB2_SS_NLOS.csv',     'NodeB3_SS_NLOS.csv', ...
             'Node01_RC_NLOS.csv',     'Node02_RC_NLOS.csv',     'Node03_RC_NLOS.csv', ...
             'Node11_Floor1_NLOS.csv', 'Node12_Floor1_NLOS.csv', 'Node13_Floor1_NLOS.csv', ...
             'Node21_Floor2_NLOS.csv', 'Node22_Floor2_NLOS.csv', 'Node23_Floor2_NLOS.csv', ...
             'Node31_Floor3_NLOS.csv', 'Node32_Floor3_NLOS.csv', 'Node33_Floor3_NLOS.csv'};
    labels = {'B1','B2','B3', '01','02','03', '11','12','13', '21','22','23', '31','32','33'};
    dists  = [28 45.3 48.2,  27 44.7 47.6,  26.4 44.3 47.3,  26 44 47,  26.2 44.1 47.1];

    snr = [];  rssi = [];  dist = [];  ids = strings(0,1);

    for f = 1:numel(files)
        data = readtable(fullfile(NODE_DIR, files{f}), ...
            'Delimiter', ';', 'ReadVariableNames', false, 'TextType', 'string');
        id_f   = string(data{:,1});
        rssi_f = data{:,13};   % ChannelRSSI_dBm
        snr_f  = data{:,14};   % SNR_dB
        if ~isnumeric(rssi_f), rssi_f = str2double(string(rssi_f)); end
        if ~isnumeric(snr_f),  snr_f  = str2double(string(snr_f));  end

        ok = ~isnan(rssi_f) & ~isnan(snr_f);
        fprintf('[Multi-floor] %-24s node %-3s  %6.1f m  valid samples: %5d of %5d\n', ...
            files{f}, labels{f}, dists(f), sum(ok), height(data));

        snr  = [snr;  snr_f(ok)];
        rssi = [rssi; rssi_f(ok)];
        dist = [dist; repmat(dists(f), sum(ok), 1)];
        ids  = [ids;  id_f(ok) + "@" + string(labels{f})];
    end
    fprintf('[Multi-floor] total valid samples: %d\n', numel(snr));

    scatter3(snr, rssi, dist, 36, dist, 'filled');
    xlabel('SNR (dB)', 'FontSize', 11);
    ylabel('RSSI (dBm)', 'FontSize', 11); % plotted value is ChannelRSSI_dBm
    zlabel('Distance (m)', 'FontSize', 11);
    grid on;
    view(45, 25);
    cb = colorbar;
    cb.Label.String = 'Distance (m)';

    % --- Export table: the exact points plotted above ---
    % DeviceID is written as <recorded Device_ID>@<Table 4 node label>.
    Environment = repmat("MultiFloorBuilding", numel(snr), 1);
    Condition = repmat("NLOS", numel(snr), 1);
    DeviceID = ids;
    SNR_dB = snr;
    RSSI_dBm = rssi;
    Distance_m = dist;
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


function rho = spearman_rho(x, y)
% Spearman rank correlation with average ranks for ties (no toolbox needed).
    R = corrcoef(avg_rank(double(x(:))), avg_rank(double(y(:))));
    rho = R(1,2);
end

function r = avg_rank(v)
    [s, idx] = sort(v);
    n = numel(v);
    ranks = zeros(n,1);
    i = 1;
    while i <= n
        j = i;
        while j < n && s(j+1) == s(i), j = j + 1; end
        ranks(i:j) = (i + j) / 2;
        i = j + 1;
    end
    r = zeros(n,1);
    r(idx) = ranks;
end
