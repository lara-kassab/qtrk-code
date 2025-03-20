function ALG_plots(alg, tdims, beta_array, betarow_array, q_array, num_trials, num_its, cor_size, corr_option)

%% Code to generate QTRK or mQTRK plots %%
tic

% Shuffle state
rngState = rng('shuffle'); 

% Create a new folder to the save figure
exp_id = randi([1, 9999]);
folderName = ['exp-',num2str(exp_id)] ;
if ~exist(folderName, 'dir') % check it does not exist
    mkdir(folderName);
end

% Save state
save(fullfile(folderName,'rngState.mat'), 'rngState');

% Pull given dimensions
l = tdims(1);
p = tdims(2);
n = tdims(3);
m = tdims(4);

disp("Experiment Folder: " + exp_id);
disp("Algorithm: " + alg);
disp("Corr. dist. = " + cor_size);
disp("beta-row = " + betarow_array);
disp("beta = " + beta_array);
disp("q = " + q_array);

%% Running Algorithm with Different Combination of Parameters

% Number of parameters
param1 = length(beta_array);
param2 = length(betarow_array);
param3 = length(q_array);

% Number of corruptions and corrupted rows
num_corrupt_array = round(beta_array*(m*p*n));
k_array = round(betarow_array*m);

% Initialize variables to determine y-axis limits
allY = zeros(param1*param2,num_its+1,param3);

% Loop through each combination of parameters to compute aggregated results
indd = 1;
for i = 1:param1
    % Define current parameters
    num_corrupt = num_corrupt_array(i);

    for j = 1:param2
        % Define current parameters
        k = k_array(j);

        for h = 1:param3
            % Define current parameters 
            q = q_array(h);

            disp(i + " out of " + param1 + " and " + j + " out of " + param2 + " and " + h + " out of " + param3)
    
            % Run Algorithm (QTRK or mQTRK)
            errs_matrix = ALG_trials(alg, tdims, num_corrupt, q, k, cor_size, num_trials, num_its);
    
            % Aggregate results
            % --- >
            % Example: Calculate median errors across trials
            median_errs = median(errs_matrix);
    
            % Collect y-values for later use
            allY(indd,:,h) = median_errs;
        end
        indd = indd  + 1;
    end
end

%% Enforcing same y-axis range for all semi-log plots

% Determine global y-axis limits
yMin = min(allY(:));
yMax = max(allY(:));

% Choice of markers, colors, and lines for plotting
colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.2, 0.2, 0.2], [0.466, 0.674, 0.188]};
lineStyles = {'-', '--',':', '-.'};
legendLabels = cell(1, param3);

% Initialize index counter for accessing allY
index = 1;

legendLabels{1} = "TRK";

for ll = 2:param3
    legendLabels{ll} = strcat('$q =$ ', num2str(round(q_array(ll),4)));
end

% Generate figures for different parameter combinations
for i = 1:param1
    for j = 1:param2

        individual_fig = figure;
        hold on

        for h = 1:param3
            median_errs = allY(index,:,h);
            if h > 4
                plot(1:100:num_its+1, median_errs(1:100:num_its+1), 'Color', colors{h}, 'Marker', 'x', 'MarkerSize', 12, 'LineStyle', '-', 'LineWidth', 5.5);
            elseif abs(beta_array(i) - (1 - q_array(h))) < 1e-7
                plot(1:num_its+1, median_errs, 'Color', colors{h},'LineStyle', lineStyles{h}, 'LineWidth', 8);
            else
                plot(1:num_its+1, median_errs, 'Color', colors{h},'LineStyle', lineStyles{h}, 'LineWidth', 5);
            end
        end

        % Set the y-axis to a logarithmic scale
        set(gca, 'YScale', 'log');
        
        % Set y-axis tick labels to be visible
        yticks([10^(-10), 10^0]);

        % Set font size for tick labels and texts
        set(gca, 'FontSize', 34); %tick labels
        xlabel('Iteration', 'interpreter','latex', FontSize=38);
        ylabel('Relative Error', 'interpreter','latex', FontSize=38);
        
        if  (i == param1) && (j==1) % show legend only once 
            legend(legendLabels,'Interpreter','latex', 'FontSize', 34);
        end

        % Set x- and y-axis limits
        ylim([yMin, yMax]);
        xlim([0, num_its]);

        % Save individual subfigures
        corr_option = char(corr_option);
        alg = char(alg);
        figFileName = fullfile(folderName, [alg, '_', corr_option, '_exp_', num2str(exp_id), '_subfig_', num2str(num_corrupt_array(i)), '_', num2str(k_array(j)), '.fig']);
        savefig(individual_fig, figFileName);

        % Save individual figures
        set(gcf, 'Position', [100, 100, 600, 400]);  % [left, bottom, width, height]
        pngFileName = fullfile(folderName, [alg, '_', corr_option, '_exp_', num2str(exp_id), '_subfig_', num2str(num_corrupt_array(i)), '_', num2str(k_array(j)), '.png']);
        print(gcf, pngFileName, '-dpng', '-r300');  % Adjust resolution as needed

        close(individual_fig);
        hold off
        
        % Update the index for the next entry
        index = index + 1;

    end
end
tmr = toc;
dt = datetime;
disp("Wall-clock time (in sec): "  + tmr)

filePath = fullfile(folderName, 'parameters.txt');
discp = fopen(filePath, 'w' );
fprintf(discp, "Date and Time of Experiment: %s\n", dt);
fprintf(discp, "Experiment Folder: %d\n", exp_id);
fprintf(discp, "Algorithm: %s\n", alg);
fprintf(discp,"Dims: l = %d, p = %d, n = %d, m = %d\n", l, p, n, m);
fprintf(discp,"Trials: %d, Iters: %d\n", num_trials, num_its);
fprintf(discp,"Corr. dist. = %d, %d\n", cor_size(1), cor_size(2));
fprintf(discp,"beta-row = %.5f\n", betarow_array);
fprintf(discp,"beta = %.5f\n", beta_array);
fprintf(discp, "q = %.5f\n", q_array);
fprintf(discp, "Wall-clock time (in sec):%.3f\n", tmr);
fclose(discp);
close all

end