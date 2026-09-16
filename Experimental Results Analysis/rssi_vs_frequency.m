% === Script: rssi_vs_frequency.m ===
% Reproduces Figure 11 of the paper: Average RSSI for each frequency band.
%
% Averages ChannelRSSI_dBm (column 13): the raw, uncorrected per-channel
% receiver measurement, used here to isolate frequency-channel propagation
% effects independently of the SNR-based adjustment applied to RSSI_dBm
% (column 12, used in Figure 10). See ../README.md, "Notes" section, for
% the full RSSI_dBm vs ChannelRSSI_dBm distinction.
%
% Column schema (see ../data/README.md):
%   Column 12 = RSSI_dBm
%   Column 13 = ChannelRSSI_dBm
%   Column 9  = Frequency_Hz
%
% Error bars show +/- 1 standard deviation of ChannelRSSI_dBm within each
% frequency/environment group, to indicate whether the differences between
% frequency channels are meaningful relative to within-channel variability.

DATA_DIR = '../Dataset/By_Environment_and_Condition/';
OUTPUT_DIR = '.';  % where the exported CSV table is written
COL_FREQ = 9;   % Frequency_Hz
COL_RSSI = 13;  % ChannelRSSI_dBm

% List of CSV files and environment/scenario names
files = {
    fullfile(DATA_DIR, 'Residential_LOS.csv'), 'Residential_LOS';
    fullfile(DATA_DIR, 'Residential_NLOS.csv'), 'Residential_NLOS';
    fullfile(DATA_DIR, 'MultiFloorBuilding_NLOS.csv'), 'MultiFloorBuilding_NLOS';
    fullfile(DATA_DIR, 'Laboratory_LOS.csv'), 'Laboratory_LOS';
    fullfile(DATA_DIR, 'Laboratory_NLOS.csv'), 'Laboratory_NLOS';
    fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario1.csv'), 'UndergroundIndustrial_Scenario1';
    fullfile(DATA_DIR, 'UndergroundIndustrial_Scenario2.csv'), 'UndergroundIndustrial_Scenario2';
};

node_names = files(:,2)';
freq_set = [];

% Structure to store mean and std RSSI per environment/frequency
rssi_data = struct();

for i = 1:size(files, 1)
    filename = files{i, 1};
    nodename = files{i, 2};

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s. Check DATA_DIR path.', filename);
    end
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    lines = lines{1};

    freq_vals = [];
    rssi_vals = [];

    % Extract frequency and RSSI (skips header row automatically via isnan check)
    for j = 1:length(lines)
        tokens = strsplit(lines{j}, ';');
        if length(tokens) >= max(COL_FREQ, COL_RSSI)
            freq = str2double(tokens{COL_FREQ});
            rssi = str2double(tokens{COL_RSSI});
            if ~isnan(freq) && ~isnan(rssi)
                freq_vals(end+1) = freq; %#ok<AGROW>
                rssi_vals(end+1) = rssi; %#ok<AGROW>
            end
        end
    end

    % Mean and standard deviation of RSSI per frequency
    unique_freqs = unique(freq_vals);
    freq_set = union(freq_set, unique_freqs);
    for k = 1:length(unique_freqs)
        f = unique_freqs(k);
        idx = freq_vals == f;
        fieldname = sprintf('f%d', f);
        rssi_data.(nodename).(fieldname).mean = mean(rssi_vals(idx));
        rssi_data.(nodename).(fieldname).std  = std(rssi_vals(idx));
        rssi_data.(nodename).(fieldname).n    = sum(idx);
    end
end

% Convert frequencies for display
freq_list = sort(freq_set);
num_nodes = length(node_names);
num_freqs = length(freq_list);
rssi_matrix = NaN(num_nodes, num_freqs);
rssi_std_matrix = NaN(num_nodes, num_freqs);
rssi_n_matrix = NaN(num_nodes, num_freqs);

% Build the mean, std and sample-size data matrices for plotting/export
for i = 1:num_nodes
    node = node_names{i};
    for j = 1:num_freqs
        freq = freq_list(j);
        fieldname = sprintf('f%d', freq);
        if isfield(rssi_data.(node), fieldname)
            rssi_matrix(i, j) = rssi_data.(node).(fieldname).mean;
            rssi_std_matrix(i, j) = rssi_data.(node).(fieldname).std;
            rssi_n_matrix(i, j) = rssi_data.(node).(fieldname).n;
        end
    end
end

% Convert to MHz for display
freq_labels = freq_list / 1e6;
names = {'Residential environment (LOS)', 'Residential environment (NLOS)',...
    'Multi-floor building (NLOS)', 'Research laboratory (LOS)','Research laboratory (NLOS)', ...
    'Underground industrial (Scenario 1)', 'Underground industrial (Scenario 2)' };

% Plot
figure;
b = bar(rssi_matrix', 'grouped');
hold on;
for k = 1:length(b)
    xpos = b(k).XEndPoints;
    errorbar(xpos, rssi_matrix(k,:), rssi_std_matrix(k,:), ...
        'k', 'linestyle', 'none', 'LineWidth', 0.8, 'CapSize', 3);
end
hold off;
xticks(1:num_freqs);
xticklabels(string(freq_labels)); % Displays 867.1, 867.3, etc.
xlabel('Frequency (\times10^6 Hz)', 'FontSize', 13);
ylabel('Mean RSSI (dBm) \pm 1 SD', 'FontSize', 13);
legend(names, 'Location', 'northeast');
grid on;
xtickangle(90);

% === Export: the exact mean/std/n values plotted above, long format ===
% One row per (node, frequency) bar+error bar actually drawn in the figure.
nRows = num_nodes * num_freqs;
Node = strings(nRows,1);
Frequency_MHz = zeros(nRows,1);
Mean_RSSI_dBm = zeros(nRows,1);
Std_RSSI_dBm = zeros(nRows,1);
N_samples = zeros(nRows,1);

r = 1;
for i = 1:num_nodes
    for j = 1:num_freqs
        Node(r) = names{i};
        Frequency_MHz(r) = freq_labels(j);
        Mean_RSSI_dBm(r) = rssi_matrix(i,j);
        Std_RSSI_dBm(r) = rssi_std_matrix(i,j);
        N_samples(r) = rssi_n_matrix(i,j);
        r = r + 1;
    end
end

T_long = table(Node, Frequency_MHz, Mean_RSSI_dBm, Std_RSSI_dBm, N_samples);
T_long = T_long(~isnan(T_long.Mean_RSSI_dBm), :);  % drop (node, freq) combos with no data
writetable(T_long, fullfile(OUTPUT_DIR, 'rssi_vs_frequency_data.csv'));

% Companion wide-format table (one row per node, one column per
% frequency), matching the layout of rssi_matrix used to draw the bars.
T_wide_mean = array2table(rssi_matrix, 'VariableNames', matlab.lang.makeValidName(string(freq_labels)+"MHz"));
T_wide_mean = [table(names', 'VariableNames', {'Node'}), T_wide_mean];
writetable(T_wide_mean, fullfile(OUTPUT_DIR, 'rssi_vs_frequency_data_wide_mean.csv'));
