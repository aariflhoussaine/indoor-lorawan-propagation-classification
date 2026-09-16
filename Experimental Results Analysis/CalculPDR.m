clear all;
clc;

% === Script: CalculPDR_Table7.m ===
% Consolidates per-node PDR calculations across all four environments into
% a single table matching the structure of Table 7 of the paper, with a
% 95% Wilson confidence interval added for each row (per reviewer
% request). Run this script directly to obtain the final table to insert
% into the manuscript; it also prints a ready-to-paste LaTeX version.

CONFIDENCE = 0.95;

% === Underground Industrial Scenario 1 / Scenario 2 mapping ===
% Filenames do not carry an explicit "Scenario1"/"Scenario2" label. This
% mapping was reconstructed from the paper's description of Scenario 1
% (all NLOS, remote/congested areas such as storage rooms, matching the
% location-coded filenames LI7/LCSE1/LCSE2/LI3) and Scenario 2 (Node1-3
% partly LOS, Node4-7 NLOS, matching the plain UP_LOS/UP_NLOS filenames).
% Corrected per author confirmation (initial version had the two
% scenarios swapped).
underground_scenario_map = containers.Map( ...
    {'Node1_UP_LOS', 'Node2_UP_LOS', 'Node3_UP_LOS', 'Node4_UP_NLOS', ...
     'Node5_BTUP_NLOS', 'Node6_LAIUP_NLOS', 'Node7_LEPEUP_NLOS', ...
     'Node1_UP_NLOS', 'Node2_UP_NLOS', 'Node3_UP_NLOS', 'Node4_LI7UP_NLOS', ...
     'Node5_LCSE1UP_NLOS', 'Node6_LCSE2UP_NLOS', 'Node7_LI3UP_NLOS'}, ...
    {'Scenario 2', 'Scenario 2', 'Scenario 2', 'Scenario 2', ...
     'Scenario 2', 'Scenario 2', 'Scenario 2', ...
     'Scenario 1', 'Scenario 1', 'Scenario 1', 'Scenario 1', ...
     'Scenario 1', 'Scenario 1', 'Scenario 1'});

% === File lists per environment (as in the individual CalculPDR_*.m scripts) ===
residential_files = {
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node1_LOS_2m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node1_NLOS_4m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node2_LOS_4m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node2_NLOS_6m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node3_LOS_5m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node3_NLOS_3.6m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node4_LOS_3.6m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node4_NLOS_2m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node5_NLOS_6m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node6_NLOS_4m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node7_NLOS_5.7m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node8_NLOS_8.5m.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Residential/Node9_NLOS_6.7m.csv'
};

laboratory_files = {
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node1_Labo_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node1_Labo_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node2_Labo_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node2_Labo_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node3_Labo_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node3_Labo_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node4_Labo_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_Laboratory/Node4_Labo_NLOS.csv'
};

multifloor_files = {
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node01_RC_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node02_RC_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node03_RC_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node11_Floor1_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node12_Floor1_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node13_Floor1_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node21_Floor2_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node22_Floor2_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node23_Floor2_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node31_Floor3_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node32_Floor3_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/Node33_Floor3_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/NodeB1_SS_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/NodeB2_SS_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_MultiFloorBuilding/NodeB3_SS_NLOS.csv'
};

underground_files = {
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node1_UP_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node1_UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node2_UP_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node2_UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node3_UP_LOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node3_UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node4_LI7UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node4_UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node5_BTUP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node5_LCSE1UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node6_LAIUP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node6_LCSE2UP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node7_LEPEUP_NLOS.csv'
    '../Dataset/By_Environment_and_Node/Nodes_UndergroundIndustrial/Node7_LI3UP_NLOS.csv'
};

% === Compute per-node results for each environment ===
[res_recus, res_attendus, res_cond] = compute_node_results(residential_files, @condition_from_los_nlos);
[lab_recus, lab_attendus, lab_cond] = compute_node_results(laboratory_files, @condition_from_los_nlos);
[mf_recus,  mf_attendus,  mf_cond]  = compute_node_results(multifloor_files, @(f) "NLOS");
[up_recus,  up_attendus,  up_cond]  = compute_node_results(underground_files, ...
    @(f) condition_from_map(f, underground_scenario_map));

% === Build the final Table 7-style summary, one row per Environment x Config ===
Environment = strings(0,1);
Config = strings(0,1);
PDR_percent = [];
CI_Low = [];
CI_High = [];

[Environment, Config, PDR_percent, CI_Low, CI_High] = add_pooled_rows( ...
    Environment, Config, PDR_percent, CI_Low, CI_High, ...
    "Residential", res_recus, res_attendus, res_cond, CONFIDENCE);

[Environment, Config, PDR_percent, CI_Low, CI_High] = add_pooled_rows( ...
    Environment, Config, PDR_percent, CI_Low, CI_High, ...
    "Laboratory", lab_recus, lab_attendus, lab_cond, CONFIDENCE);

[Environment, Config, PDR_percent, CI_Low, CI_High] = add_pooled_rows( ...
    Environment, Config, PDR_percent, CI_Low, CI_High, ...
    "Multi-floor", mf_recus, mf_attendus, mf_cond, CONFIDENCE);

[Environment, Config, PDR_percent, CI_Low, CI_High] = add_pooled_rows( ...
    Environment, Config, PDR_percent, CI_Low, CI_High, ...
    "Underground", up_recus, up_attendus, up_cond, CONFIDENCE);

Table7_with_CI = table(Environment, Config, PDR_percent, CI_Low, CI_High);

% === Add a Mean PDR (%) column per environment, matching Table 7's format ===
MeanPDR = zeros(height(Table7_with_CI), 1);
envs = unique(Environment, 'stable');
for e = 1:length(envs)
    mask = Environment == envs(e);
    MeanPDR(mask) = mean(PDR_percent(mask));
end
Table7_with_CI.Mean_PDR_percent = round(MeanPDR, 2);

disp(Table7_with_CI);
writetable(Table7_with_CI, 'Table7_PDR_with_CI.csv');

% === Print a ready-to-paste LaTeX version ===
fprintf('\n%% --- LaTeX table (paste into the manuscript) ---\n');
fprintf('\\begin{table}[t]\n');
fprintf('\\caption{Packet Delivery Rate per Environment and Configuration, with 95%% Wilson Confidence Intervals}\\label{tab:pdr_ci}\n');
fprintf('\\renewcommand{\\arraystretch}{1.4}\n');
fprintf('\\begin{tabular}{|l|l|c|c|c|}\n');
fprintf('\\hline\n');
fprintf('\\textbf{Environment} & \\textbf{Config.} & \\textbf{PDR (\\%%)} & \\textbf{95\\%% CI} & \\textbf{Mean PDR (\\%%)} \\\\\n');
fprintf('\\hline\n');
prevEnv = "";
for i = 1:height(Table7_with_CI)
    envLabel = "";
    if Table7_with_CI.Environment(i) ~= prevEnv
        envLabel = Table7_with_CI.Environment(i);
        prevEnv = Table7_with_CI.Environment(i);
    end
    fprintf('%s & %s & %.2f & [%.2f, %.2f] & %.2f \\\\\n', ...
        envLabel, Table7_with_CI.Config(i), Table7_with_CI.PDR_percent(i), ...
        Table7_with_CI.CI_Low(i), Table7_with_CI.CI_High(i), Table7_with_CI.Mean_PDR_percent(i));
end
fprintf('\\hline\n');
fprintf('\\end{tabular}\n');
fprintf('\\end{table}\n');


% ============================================================
% Local functions
% ============================================================

function cond = condition_from_los_nlos(filename)
    name_upper = upper(filename);
    if contains(name_upper, 'NLOS')
        cond = "NLOS";
    elseif contains(name_upper, 'LOS')
        cond = "LOS";
    else
        cond = "Unknown";
    end
end

function cond = condition_from_map(filename, scenario_map)
    [~, nomFichier, ~] = fileparts(filename);
    if isKey(scenario_map, nomFichier)
        cond = scenario_map(nomFichier);
    else
        cond = "Unknown";
    end
end

function [recus, attendus, cond] = compute_node_results(files, cond_fn)
    N = length(files);
    recus = zeros(N,1);
    attendus = zeros(N,1);
    cond = strings(N,1);
    for i = 1:N
        data = readtable(files{i}, 'TextType', 'string');
        [~, ~, ~, nb_attendus, nb_recus, ~] = calculerPDR_fromTable(data);
        recus(i) = nb_recus;
        attendus(i) = nb_attendus;
        cond(i) = cond_fn(files{i});
    end
end

function [Environment, Config, PDR_percent, CI_Low, CI_High] = add_pooled_rows( ...
    Environment, Config, PDR_percent, CI_Low, CI_High, envName, recus, attendus, cond, confidence)

    conds = unique(cond);
    for c = 1:length(conds)
        mask = cond == conds(c);
        sum_recus = sum(recus(mask));
        sum_attendus = sum(attendus(mask));
        pooled_pdr = sum_recus / sum_attendus;
        [pl, ph] = wilson_ci(sum_recus, sum_attendus, confidence);

        Environment(end+1,1) = envName; %#ok<AGROW>
        Config(end+1,1) = conds(c); %#ok<AGROW>
        PDR_percent(end+1,1) = round(pooled_pdr * 100, 2); %#ok<AGROW>
        CI_Low(end+1,1) = round(pl * 100, 2); %#ok<AGROW>
        CI_High(end+1,1) = round(ph * 100, 2); %#ok<AGROW>
    end
end

function [t1, t2, duree_sec, nb_attendus, nb_recus, pdr] = calculerPDR_fromTable(data)
    timestamps = data{:,9};
    candidate_formats = {
        'yyyy-MM-dd HH:mm:ss.SSSSSS'
        'yyyy-MM-dd HH:mm:ss.SSS'
        'yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''
        'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z'''
    };
    time_dt = [];
    lastErr = [];
    for k = 1:numel(candidate_formats)
        try
            time_dt = datetime(timestamps, 'InputFormat', candidate_formats{k}, 'TimeZone', 'UTC');
            break;
        catch err
            lastErr = err;
        end
    end
    if isempty(time_dt)
        rethrow(lastErr);
    end

    t1 = min(time_dt);
    t2 = max(time_dt);
    duree_sec = seconds(t2 - t1);
    intervalle = 30;
    nb_attendus = floor(duree_sec / intervalle) + 1;
    nb_recus = height(data);
    pdr = nb_recus / nb_attendus;
end
