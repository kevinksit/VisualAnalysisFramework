clear

% get both the oddball and the manystandards, process both, then compare
addpath('E:\_Code\VisualAnalysisFramework');

% Go into each folder to get the appropriate DFF
disp('Choose your many standards directory:')
ms_dir = uigetdir();
cd(ms_dir);
ms = Processor('DFF.mat');
cd('..')

disp('Choose your oddball directory:')
ob_dir = uigetdir();
cd(ob_dir);
ob = Processor('DFF.mat');
cd('..')

% Instantiate processors
init_dir = cd(ms_dir);
ms.sortData();

cd(ob_dir);
ob.sortData();

cd(init_dir);

% Define stuff 
deviant_id = 1;
standard_id = 2;

% Preparing stuff
ms_resp = ms.getProcessedData();
ob_resp = ob.getProcessedData();
ms_stim = ms.getStimdat();
ob_stim = ob.getStimdat();

% Meaning across images and on_frames
% landed on "max" to remove negatives?
standard_ms = mean(mean(mean(ms_resp(:, :, 3:10, ms_stim.img_id == standard_id, :), 3), 4), 5);
deviant_ms = mean(mean(mean(ms_resp(:, :, 3:10, ms_stim.img_id == deviant_id, :), 3), 4), 5);
standard_ob = mean(mean(mean(ob_resp(:, :, 3:10, ob_stim.img_id == standard_id, :), 3), 4), 5);
deviant_ob = mean(mean(mean(ob_resp(:, :, 3:10, ob_stim.img_id == deviant_id, :), 3), 4), 5);

% %should I bring everything positive?
% standard_ms = standard_ms - min(standard_ms(:));
% deviant_ms = deviant_ms - min(deviant_ms(:));
% standard_ob = standard_ob - min(standard_ob(:));
% deviant_ob = deviant_ob - min(deviant_ob(:));

% Calculating AI
calculateAI = @(x, c) (x - c)./(abs(x) + abs(c)); % this only works if everything is positive?

standard_ai = calculateAI(standard_ob, standard_ms);
deviant_ai = calculateAI(deviant_ob, deviant_ms);

figure
subplot(1, 2, 1)
imagesc(rot90(standard_ai));
axis square

subplot(1, 2, 2)
axis square
imagesc(rot90(deviant_ai));
axis square

% not sure what to do from here...
save('predictive_coding_maps.mat', 'standard_ai', 'deviant_ai')

[fn, pn] = uigetfile('*.mat');
load([pn '/' fn]);
try
    load('rois.mat')
catch
    HVAChooserGUI(maps)
    save rois.mat rois
end

fields = fieldnames(rois);
for f = 1:length(fields)
    standard_resp(f) = mean(standard_ai(rois.(fields{f})));
    deviant_resp(f) = mean(deviant_ai(rois.(fields{f})));
end

%{

Old

resp_matrix = p.getProcessedData();
stimdat = p.getStimdat();

img_resp = squeeze(mean(resp_matrix, 3));

a_resp = img_resp(:, :, stimdat.sampling_vector == 1, :);
b_resp = img_resp(:, :, stimdat.sampling_vector == 2, :);


a_mean_resp = squeeze(mean(a_resp, 3));
b_mean_resp = squeeze(mean(b_resp, 3));

diff_map = rot90(a_mean_resp - b_mean_resp);

imagesc(mean(diff_map, 3))

mean_diff_map = mean(diff_map, 3);
imagesc(mean_diff_map);
mean_diff_map(VFS_boundaries) = max(mean_diff_map(:))*1.1;
%}