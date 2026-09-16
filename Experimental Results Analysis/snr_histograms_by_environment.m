% Input columns expected (see ../data/README.md for full schema):
%   Column 14 = SNR_dB
DATA_DIR = '../Dataset/By_Environment_and_Condition/';
OUTPUT_DIR = '.';  % where the exported CSV table is written

% === Step 1: Define groups ===
groups = {
    {'Residential_LOS.csv', 'Residential_NLOS.csv'}, '(a) Residential environment';
    {'MultiFloorBuilding_NLOS.csv'}, '(b) Multi-floor building';
    {'Laboratory_LOS.csv', 'Laboratory_NLOS.csv'}, '(c) Research laboratory';
    {'UndergroundIndustrial_Scenario1.csv', 'UndergroundIndustrial_Scenario2.csv'}, '(d) Underground industrial'
};
% === Étape 2 : Couleurs uniformes ===
groupColors = {
    [1.0, 0.6, 0.0; 1, 0.8, 0.1];   % Residential : orange / jaune
    [1.0, 0.6, 0.0];                % Multi-floor : orange
    [1.0, 0.6, 0.0; 1, 0.8, 0.1];   % Laboratory : orange / jaune
    [1.0, 0.6, 0.0; 1, 0.8, 0.1];   % Underground : orange / jaune
};
% Darker line color per series, used for the bar-top envelope curve
% (same hue as the bars but shaded down, so the line reads clearly on
% top of the semi-transparent histogram).
lineColors = cellfun(@(c) c * 0.65, groupColors, 'UniformOutput', false);

% === Step 3: Manual legends for each subplot ===
manualLegends = {
    {'LOS', 'NLOS'};
    {'NLOS'};
    {'LOS', 'NLOS'};
    {'Scenario 1', 'Scenario 2'}
};

BIN_WIDTH = 0.25;  % dB -- single source of truth, also used in titles now

% === Step 4: Create the figure ===
figure('Name','Distribution du SNR par groupe','NumberTitle','off');

% Accumulator for the exported table: one row per (bin, series) drawn.
exportRows = table();
axesHandles = gobjects(size(groups,1),1);  % to link y-axes at the end

% === Étape 5 : Boucle sur les groupes ===
for g = 1:size(groups, 1)
    axesHandles(g) = subplot(2, 2, g);
    hold on;
    files = groups{g, 1};
    groupLabel = groups{g, 2};
    colors = groupColors{g};
    lcolors = lineColors{g};
    legends = manualLegends{g};
for f = 1:length(files)
        filename = fullfile(DATA_DIR, files{f});
% Read the CSV file honoring the header (named columns)
        data = readtable(filename, 'Delimiter', ';');
% Check the SNR_dB column (column 14)
if size(data, 2) < 14
            warning('Fichier %s : moins de 14 colonnes.', filename);
continue;
end
        snr = data{:,14};
if iscell(snr), snr = str2double(snr); end
        snr = snr(~isnan(snr));
% Tracer l'histogramme avec couleur propre au fichier
% NOTE: 'Normalization','probability' makes each bar the fraction of
% THIS series' own packets in that bin (sums to 1 across all bins),
% independent of how many packets that environment happened to collect.
        h = histogram(snr, ...
'BinWidth', BIN_WIDTH, ...
'Normalization', 'probability', ...
'EdgeColor', 'none', ...
'FaceAlpha', 0.65, ...
'FaceColor', colors(f,:), ...
'DisplayName', legends{f});

% --- Curve linking the top of the bars (frequency-polygon envelope) ---
% BinEdges/Values are only populated once the histogram has been drawn,
% so we read them back from the handle right after creating it.
        binCenters = h.BinEdges(1:end-1) + diff(h.BinEdges) / 2;
        binFreq = h.Values;  % now relative frequencies, not raw counts
        plot(binCenters, binFreq, '-', ...
'Color', lcolors(f,:), ...
'LineWidth', 1.4, ...
'HandleVisibility', 'off');  % keep it out of the legend; color already ties it to its bars

% --- Export: the exact (bin center, relative frequency) pairs drawn above ---
        nBins = length(binCenters);
        rowsThisSeries = table( ...
            repmat(string(groupLabel), nBins, 1), ...
            repmat(string(legends{f}), nBins, 1), ...
            binCenters(:), ...
            binFreq(:), ...
            'VariableNames', {'Environment', 'Series', 'BinCenter_SNR_dB', 'RelativeFrequency'});
        exportRows = [exportRows; rowsThisSeries]; %#ok<AGROW>
end
% Personnalisation du subplot
    title(sprintf('%s (bin width = %.2f dB)', groupLabel, BIN_WIDTH), ...
        'FontWeight', 'bold', 'FontSize', 11);
    xlabel('SNR (dB)', 'FontSize', 13);
    ylabel('Relative frequency', 'FontSize', 13);
    legend('show', 'Location', 'best', 'Box', 'off');
    grid on;
    hold off;
end

% === Step 5b: Harmonize y-axis across all 4 subplots ===
% Without this, panel (a)/(c) (sharp single peak, few series) and panel
% (b)/(d) (flatter, more spread out) would still visually mislead even
% in relative-frequency form, because Matlab auto-scales each axis
% independently. linkaxes forces the same y-range everywhere so peak
% heights are directly comparable across environments.
%linkaxes(axesHandles, 'y');

% === Étape 6 : Ajustement global ===
set(gcf, 'Position', [100, 100, 1100, 700]);

% === Step 7: Export the histogram values (bin center + relative frequency per series) ===
writetable(exportRows, fullfile(OUTPUT_DIR, 'snr_histogram_data.csv'));