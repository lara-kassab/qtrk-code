function deblurring_plots(X, h, num_its, num_corrupt, q, k, mean_corrupt, deviation_corrupt)

% Shuffle state
rngState = rng('shuffle'); 

% Create a new folder to the save figure
exp_id = randi([1, 9999]);
folderName = ['exp-',num2str(exp_id)] ;
if ~exist(folderName, 'dir') % check it does not exist
    mkdir(folderName);
end

disp("Experiment Folder: " + exp_id);

% Save state
save(fullfile(folderName,'rngState.mat'), 'rngState');

%% Set up the Problem

% Pull given dimensions
[l,p,n] = size(X);

% Create circularly blurred images
Y = zeros(l,p,n);
for i = 1:n
    Y(:,:,i) = blurryimage(X(:,:,i), h, [l,p]);
end
Y_uncorrupted = Y;

% Generate random corruption values
corruption_values = abs(normrnd(mean_corrupt, deviation_corrupt, [num_corrupt, 1]));

% Generate k random row indices to corrupt
corrupt_rows = randsample(l, k, false);

% Distribute num_corrupt corruptions uniformly across the k rows
for i = 1:num_corrupt
    % Select a random row from the chosen rows
    row_idx = corrupt_rows(randsample(k, 1));

    % Randomly select indices for the other dimensions
    col_idx = randsample(p, 1);
    depth_idx = randsample(n, 1);

    % Apply the corruption value
    Y(row_idx, col_idx, depth_idx) = Y(row_idx, col_idx, depth_idx) + corruption_values(i);
end

% Creating a t-linear system corresponding to the deblurring problem

Y_reorder = reorder_tensor(Y,[l,p,n]);
Y_uncorrupted = reorder_tensor(Y_uncorrupted,[l,p,n]);


%Defining the t-linear measurement operator
A = circ_blurring_mxop(h, [l,p,n]);
X0 = zeros(p,n,l);

%% Run Algorithms

% Run QTRK
[Z,QTRK_its] = QTRK_Algorithm(A,Y_reorder,X0,num_its, q);
QTRK_errs = zeros(1,num_its+1);
Z_qtrk = recover_img(Z,[l,p,n]);

% Run mQTRK
[Z,mQTRK_its] = mQTRK_Algorithm(A,Y_reorder,X0,num_its, q);
mQTRK_errs = zeros(1,num_its+1);
Z_mqtrk = recover_img(Z,[l,p,n]);

for i = 1:num_its + 1
    QTRK_res = tprod(A,QTRK_its{i}) - Y_uncorrupted;
    QTRK_errs(1,i) = norm(QTRK_res(:))/norm(Y_uncorrupted(:));
    mQTRK_res = tprod(A,mQTRK_its{i}) - Y_uncorrupted;
    mQTRK_errs(1,i) = norm(mQTRK_res(:))/norm(Y_uncorrupted(:));
end

Y_corrupted = recover_img(Y_reorder, [l,p,n]);


%% Plot Results 

grid_fig = figure; 
tiledlayout(5,4,'TileSpacing','none');
colormap gray

for i = 1:4
    nexttile;
    imagesc(X(:,:,i),[0,1]);
    title(sprintf('Frame %d',i), 'FontSize',13)
    if i == 1
        ylabel("Original",'FontSize',12);
    end
    grid off
    set(gca,'TickLength',[0 0])
    set(gca,'Yticklabel',[]) 
    set(gca,'Xticklabel',[])
end

for i = 1:4
    nexttile;
    imagesc(Y_corrupted(:,:,i));
    if i == 1
        ylabel("Blurry & Corrupted",'FontSize',12);
    end
    grid off
    set(gca,'TickLength',[0 0])
    set(gca,'Yticklabel',[]) 
    set(gca,'Xticklabel',[])
end

for i = 1:4
    nexttile;
    imagesc(Z_qtrk(:,:,i),[0,1]);
    if i == 1
        ylabel("QTRK",'FontSize',12);
    end
    grid off
    set(gca,'TickLength',[0 0])
    set(gca,'Yticklabel',[]) 
    set(gca,'Xticklabel',[])
end

for i = 1:4
    nexttile;
    imagesc(Z_mqtrk(:,:,i),[0,1]);
    if i == 1
        ylabel("mQTRK",'FontSize',12);
    end
    grid off
    set(gca,'TickLength',[0 0])
    set(gca,'Yticklabel',[]) 
    set(gca,'Xticklabel',[])
end

% Calculate least-norm solution
X_ln = tprod(tpinv(A),Y_reorder);
X_ln = recover_img(X_ln,[l,p,n]);
for i = 1:4
    nexttile;
    imagesc(X_ln(:,:,i),[0,1]);
    if i == 1
        ylabel("Least Norm",'FontSize',12);
    end
    grid off
    set(gca,'TickLength',[0 0])
    set(gca,'Yticklabel',[]) 
    set(gca,'Xticklabel',[])
end

% Save figures
figFileName = fullfile(folderName, ['mQTRK_QTRK_deblurring','_exp_', num2str(exp_id), '.fig']);
savefig(grid_fig, figFileName);

set(gcf, 'Position', [100, 100, 300, 500]);  % [left, bottom, width, height]
pngFileName = fullfile(folderName, ['mQTRK_QTRK_deblurring','_exp_', num2str(exp_id), '.png']);
print(gcf, pngFileName, '-dpng', '-r300');  % Adjust resolution as needed

close(gcf);
hold off

% Plot Error Plots
% Choice of markers, colors, and lines for plotting
colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980]};
markers = {'o', '*'};
lineStyles = {'-', ':'};

error_fig = figure;
hold on

plot(1:100:num_its+1, QTRK_errs(1:100:num_its+1), 'Color', colors{1}, 'Marker', markers{1}, 'MarkerSize', 12, 'LineStyle', lineStyles{1}, 'LineWidth', 4);
plot(1:100:num_its+1, mQTRK_errs(1:100:num_its+1), 'Color', colors{2}, 'Marker', markers{2}, 'MarkerSize', 12, 'LineStyle', lineStyles{2}, 'LineWidth', 4);

set(gca, 'YScale', 'log');

% Set font size for tick labels and texts
set(gca, 'FontSize', 24); %tick labels
xlabel('Iteration', 'interpreter','latex', FontSize=30);
ylabel('Relative Error', 'interpreter','latex', FontSize=30);
legend({'QTRK', 'mQTRK'},'Interpreter','latex', 'FontSize', 24, 'Location','northeast');

% Save figures
figFileName = fullfile(folderName, ['mQTRK_QTRK_deblurring_error','_exp_', num2str(exp_id), '.fig']);
savefig(error_fig, figFileName);

set(gcf, 'Position', [100, 100, 500, 400]);  % [left, bottom, width, height]
pngFileName = fullfile(folderName, ['mQTRK_QTRK_deblurring_error','_exp_', num2str(exp_id), '.png']);
print(gcf, pngFileName, '-dpng', '-r300');  % Adjust resolution as needed

close(gcf);
hold off
close all;

dt = datetime;
filePath = fullfile(folderName, 'parameters.txt');
discp = fopen(filePath, 'w' );
fprintf(discp, "Date and Time of Experiment: %s\n", dt);
fprintf(discp, "Experiment Folder: %d\n", exp_id);
fprintf(discp,"Dims: l = %d, p = %d, n = %d\n", l, p, n);
fprintf(discp,"Corr. dist. = %d, %d\n", mean_corrupt, deviation_corrupt);
fprintf(discp,"k = %d\n", k);
fprintf(discp,"numb. corrupt = %d\n", num_corrupt);
fprintf(discp, "q = %.5f\n", q);
fclose(discp);
close all

end
