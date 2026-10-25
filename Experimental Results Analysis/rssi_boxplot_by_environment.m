% === Script: rssi_boxplot_by_environment.m ===
% Reproduces Figure 10: RSSI distribution across environments,
% conditions and scenarios (7 boxes).
% Column 12 = RSSI_dBm. Run from the matlab/ folder, or adjust DATA_DIR.

clc; clear; close all;

% === Configuration ===
DATA_DIR   = '../Dataset/By_Environment_and_Condition/';
OUTPUT_DIR = '.';

% === Step 1: Read the CSV files ===
files = { ...
    'Residential_LOS.csv', ...
    'Residential_NLOS.csv', ...
    'MultiFloorBuilding_NLOS.csv', ...
    'Laboratory_LOS.csv', ...
    'Laboratory_NLOS.csv', ...
    'UndergroundIndustrial_Scenario1.csv', ...
    'UndergroundIndustrial_Scenario2.csv'};

rssi = cell(7,1);
for k = 1:7
    d = readtable(fullfile(DATA_DIR, files{k}));
    rssi{k} = d{:,12};              % column 12 = RSSI_dBm
end

% === Step 2: Group names ===
site_names = {'Residential','Residential','Multi-floor','Laboratory','Laboratory','Industrial','Industrial'};
cond_names = {'LOS','NLOS','NLOS','LOS','NLOS','Scenario 1','Scenario 2'};
site_full  = {'Residential environment','Residential environment','Multi-floor building', ...
              'Research laboratory','Research laboratory','Underground industrial','Underground industrial'};
n_k = cellfun(@numel, rssi);

% === Step 3: Data vector, numeric group index and positions ===
rssi_all = vertcat(rssi{:});
grp = repelem((1:7)', n_k);
pos = [1 2  3.6  5.2 6.2  7.8 8.8];     % gaps between environments

% === Step 4: Colours per environment ===
c_apartment = [0 0.4470 0.7410];      % blue
c_emsi      = [0.4660 0.6740 0.1880]; % green
c_labo      = [0.8500 0.3250 0.0980]; % orange
c_up        = [0.4940 0.1840 0.5560]; % purple
colors = [c_apartment; c_apartment; c_emsi; c_labo; c_labo; c_up; c_up];

% === Step 5: Plot ===
fig = figure('Color','w','Units','inches','Position',[1 1 12 6.4]);
boxplot(rssi_all, grp, ...
    'Positions', pos, ...
    'Colors', 'k', ...
    'Symbol', 'r+', ...
    'Whisker', 1.5, ...
    'Widths', 0.7);

ax = gca;
ax.FontSize = 12;
ax.LineWidth = 1.2;
ax.XTick = pos;
ax.XTickLabel = [];                       % labels drawn manually (Step 7b)
ax.Position = [0.08 0.22 0.90 0.66];      % room for 3-line labels below
ax.YGrid = 'on'; ax.XGrid = 'off';
ax.Box = 'on';
ylabel('RSSI (dBm)', 'FontSize', 13);
xlim([0.3 9.5]);
ylim([min(rssi_all)-8, max(rssi_all)+8]);
hold on;

% === Step 6: Colour each box, then bring medians to the front ===
boxes = findobj(ax, 'Tag', 'Box');          % returned in reverse order
for j = 1:length(boxes)
    patch(get(boxes(j),'XData'), get(boxes(j),'YData'), ...
          colors(length(boxes)-j+1,:), ...
          'FaceAlpha', 0.6, 'EdgeColor', 'k', 'LineWidth', 1.2);
end
med = findobj(ax, 'Tag', 'Median');
set(med, 'Color', 'k', 'LineWidth', 3);
uistack(med, 'top');
set(findobj(ax,'Tag','Outliers'), 'MarkerSize', 5);

% === Step 7: Separators between environments ===
yl = ylim;
for xs = [2.8 4.4 7.0]
    plot([xs xs], yl, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
end

% === Step 7b: Manual 3-line tick labels (one cell per line) ===
dy = yl(2) - yl(1);
for k = 1:7
    nstr = regexprep(num2str(n_k(k)), '(\d)(?=(\d{3})+$)', '$1,');
    lbl  = {site_names{k}; cond_names{k}; sprintf('(n = %s)', nstr)};
    text(pos(k), yl(1) - 0.02*dy, lbl, ...
        'HorizontalAlignment','center', 'VerticalAlignment','top', ...
        'FontSize', 11, 'Clipping','off', 'Interpreter','none');
end
xl = xlabel('Environments, conditions and scenarios', 'FontSize', 13);
xl.Units = 'normalized';
xl.Position = [0.5 -0.20 0];              % push title below the labels

% === Step 8: Legend above the plot (does not hide any data) ===
h1 = plot(NaN,NaN,'s','MarkerFaceColor',c_apartment,'MarkerEdgeColor','k','MarkerSize',11);
h2 = plot(NaN,NaN,'s','MarkerFaceColor',c_emsi,'MarkerEdgeColor','k','MarkerSize',11);
h3 = plot(NaN,NaN,'s','MarkerFaceColor',c_labo,'MarkerEdgeColor','k','MarkerSize',11);
h4 = plot(NaN,NaN,'s','MarkerFaceColor',c_up,'MarkerEdgeColor','k','MarkerSize',11);
legend([h1 h2 h3 h4], {'Residential environment','Multi-floor building', ...
    'Research laboratory','Underground industrial'}, ...
    'Location','northoutside','Orientation','horizontal', ...
    'Box','off','FontSize',12);
hold off;

% === Step 9: Export the values used (raw + summary) ===
site = strings(numel(rssi_all),1);  sous_groupe = strings(numel(rssi_all),1);
idx = 0;
for k = 1:7
    r = idx+1 : idx+n_k(k);
    site(r) = site_full{k};  sous_groupe(r) = cond_names{k};
    idx = idx + n_k(k);
end
T_raw = table(rssi_all, site, sous_groupe, ...
    'VariableNames', {'RSSI_dBm','Environment','Condition'});
writetable(T_raw, fullfile(OUTPUT_DIR,'rssi_boxplot_data_raw.csv'));

Environment = strings(7,1); Condition = strings(7,1);
N = n_k; Median = zeros(7,1); Q1 = zeros(7,1); Q3 = zeros(7,1);
WhiskerLow = zeros(7,1); WhiskerHigh = zeros(7,1); NOutliers = zeros(7,1);
for k = 1:7
    v = rssi{k};
    Environment(k) = site_full{k};  Condition(k) = cond_names{k};
    Median(k) = median(v);  Q1(k) = prctile(v,25);  Q3(k) = prctile(v,75);
    iq = Q3(k)-Q1(k);
    lo = Q1(k)-1.5*iq;  hi = Q3(k)+1.5*iq;
    inR = v(v>=lo & v<=hi);
    WhiskerLow(k) = min(inR);  WhiskerHigh(k) = max(inR);
    NOutliers(k) = sum(v<lo | v>hi);
end
T_summary = table(Environment,Condition,N,Median,Q1,Q3,WhiskerLow,WhiskerHigh,NOutliers);
writetable(T_summary, fullfile(OUTPUT_DIR,'rssi_boxplot_data_summary.csv'));

% === Step 10: Export (page fitted to the figure) ===
exportgraphics(fig, 'Fig10.pdf', 'ContentType','vector', 'BackgroundColor','white');
exportgraphics(fig, 'Fig10.eps', 'ContentType','vector', 'BackgroundColor','white');
fprintf('Figure 10 exported: Fig10.pdf / Fig10.eps\n');