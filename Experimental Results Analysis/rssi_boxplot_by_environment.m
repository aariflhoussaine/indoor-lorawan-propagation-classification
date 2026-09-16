% === Script: rssi_boxplot_by_environment.m ===
% Reproduces Figure 10 of the paper: RSSI distribution across environments,
% conditions and scenarios.
%
% Input columns expected (see ../data/README.md for full schema):
%   Column 12 = RSSI_dBm
%
% Usage: run from the matlab/ folder, or adjust DATA_DIR below.

clc; clear; close all;

% === Configuration ===
DATA_DIR = '../Dataset/By_Environment_and_Condition/';
OUTPUT_DIR = '.';  % where the exported CSV table is written

% === Étape 1 : Lire les fichiers CSV ===
data1 = readtable(fullfile(DATA_DIR, 'Residential_LOS.csv'));
data2 = readtable(fullfile(DATA_DIR, 'Residential_NLOS.csv'));
data3 = readtable(fullfile(DATA_DIR, 'MultiFloorBuilding_NLOS.csv'));
data4 = readtable(fullfile(DATA_DIR, 'Laboratory_LOS.csv'));
data5 = readtable(fullfile(DATA_DIR, 'Laboratory_NLOS.csv'));
data6 = readtable(fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario1.csv'));
data7 = readtable(fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario2.csv'));

% === Étape 2 : Extraire la colonne RSSI (colonne 12 = RSSI_dBm) ===
rssi1 = data1{:,12};
rssi2 = data2{:,12};
rssi3 = data3{:,12};
rssi4 = data4{:,12};
rssi5 = data5{:,12};
rssi6 = data6{:,12};
rssi7 = data7{:,12};

% === Step 3: Concatenate all data ===
rssi_all = [rssi1; rssi2; rssi3; rssi4; rssi5; rssi6; rssi7];

% === Step 4: Build hierarchical groups ===
site = [ ...
    repmat("Residential environment", length(rssi1)+length(rssi2), 1); ...
    repmat("Multi-floor building", length(rssi3), 1); ...
    repmat("Research laboratory", length(rssi4)+length(rssi5), 1); ...
    repmat("Underground industrial", length(rssi6)+length(rssi7), 1)];

sous_groupe = [ ...
    repmat("LOS", length(rssi1), 1); ...
    repmat("NLOS", length(rssi2), 1); ...
    repmat("NLOS", length(rssi3), 1); ...
    repmat("LOS", length(rssi4), 1); ...
    repmat("NLOS", length(rssi5), 1); ...
    repmat("Scenario 1", length(rssi6), 1); ...
    repmat("Scenario 2", length(rssi7), 1)];

% === Step 5: Define distinct colors per site ===
c_apartment = [0 0.4470 0.7410];   % bleu
c_emsi      = [0.4660 0.6740 0.1880]; % vert
c_labo      = [0.8500 0.3250 0.0980]; % orange
c_up        = [0.4940 0.1840 0.5560]; % violet

colors = [ ...
    c_apartment; c_apartment; ...
    c_emsi; ...
    c_labo; c_labo; ...
    c_up; c_up];

% === Étape 6 : Tracer le boxplot principal ===
figure('Color','w','Position',[100 100 1000 500]);
h = boxplot(rssi_all, {site, sous_groupe}, ...
    'factorseparator', 1, ...
    'Colors','k', ...
    'Symbol','r+', ...
    'Whisker',1.5, ...
    'Widths',0.5);

ylabel('RSSI (dBm)', 'FontSize', 13);
xlabel('Environments, conditions and scenarios', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.2);
xtickangle(25);

% === Step 7: Color each box ===
boxes = findobj(gca, 'Tag', 'Box');
for j = 1:length(boxes)
    patch(get(boxes(j), 'XData'), get(boxes(j), 'YData'), ...
          colors(length(boxes)-j+1,:), ...
          'FaceAlpha', 0.6, 'EdgeColor', 'k', 'LineWidth', 1.2);
end

% === Step 8: Add legend with enlarged markers ===
hold on;
h1 = plot(NaN, NaN, 's', 'MarkerFaceColor', c_apartment, 'MarkerEdgeColor', 'k', 'MarkerSize', 13);
h2 = plot(NaN, NaN, 's', 'MarkerFaceColor', c_emsi,      'MarkerEdgeColor', 'k', 'MarkerSize', 13);
h3 = plot(NaN, NaN, 's', 'MarkerFaceColor', c_labo,      'MarkerEdgeColor', 'k', 'MarkerSize', 13);
h4 = plot(NaN, NaN, 's', 'MarkerFaceColor', c_up,        'MarkerEdgeColor', 'k', 'MarkerSize', 13);

legend([h1 h2 h3 h4], {'Residential environment','Multi-floor building','Research laboratory','Underground industrial'}, ...
    'Location','best', ...
    'Box','off', ...
    'FontSize', 13, ...
    'FontWeight','bold');

hold off;

% === Étape 9 : Ajustement final ===
ylim([min(rssi_all)-10, max(rssi_all)+5]);
box on;

% === Step 10: Export the exact values used in the boxplot ===
% One row per packet: its RSSI value plus the environment/condition group
% it belongs to (i.e. the raw data underlying each box/whisker).
T_raw = table(rssi_all, site, sous_groupe, ...
    'VariableNames', {'RSSI_dBm', 'Environment', 'Condition'});
writetable(T_raw, fullfile(OUTPUT_DIR, 'rssi_boxplot_data_raw.csv'));

% Companion summary table: the actual statistics each box represents
% (median, quartiles, whiskers, outlier count), one row per box.
groupKeys = unique(strcat(site, " | ", sous_groupe), 'stable');
nGroups = length(groupKeys);
Environment = strings(nGroups,1);
Condition = strings(nGroups,1);
N = zeros(nGroups,1);
Median = zeros(nGroups,1);
Q1 = zeros(nGroups,1);
Q3 = zeros(nGroups,1);
WhiskerLow = zeros(nGroups,1);
WhiskerHigh = zeros(nGroups,1);
NOutliers = zeros(nGroups,1);

for i = 1:nGroups
    parts = strsplit(groupKeys(i), " | ");
    mask = site == parts(1) & sous_groupe == parts(2);
    vals = rssi_all(mask);
    Environment(i) = parts(1);
    Condition(i) = parts(2);
    N(i) = sum(mask);
    Median(i) = median(vals);
    Q1(i) = prctile(vals, 25);
    Q3(i) = prctile(vals, 75);
    iqr_val = Q3(i) - Q1(i);
    lowFence = Q1(i) - 1.5*iqr_val;
    highFence = Q3(i) + 1.5*iqr_val;
    inRange = vals(vals >= lowFence & vals <= highFence);
    WhiskerLow(i) = min(inRange);
    WhiskerHigh(i) = max(inRange);
    NOutliers(i) = sum(vals < lowFence | vals > highFence);
end

T_summary = table(Environment, Condition, N, Median, Q1, Q3, WhiskerLow, WhiskerHigh, NOutliers);
writetable(T_summary, fullfile(OUTPUT_DIR, 'rssi_boxplot_data_summary.csv'));
