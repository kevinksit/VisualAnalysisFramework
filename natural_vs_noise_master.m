addpath('E:\_Code\VisualAnalysisFramework');
p = Processor('DFF.mat');
p.sortData();

resp_matrix = p.getProcessedData();

% further separation...
% 30 images, 2 seconds each
resp_matrix = squeeze(resp_matrix);

img_resp = zeros(size(resp_matrix, 1), size(resp_matrix, 2), 30, size(resp_matrix, 4));
for p = 1:30
    curr = (p - 1) * 20;
    img_resp(:, :, p, :) = mean(resp_matrix(:, :, curr + 1:curr + 20, :), 3);
end


coherence_map = zeros(size(img_resp, 1), size(img_resp, 2), size(img_resp, 4));
for y = 1:size(img_resp, 1)
    for x = 1:size(img_resp, 2)
        for r = 1:size(img_resp, 4)
            coherence_map(y, x, r) = corr(squeeze(img_resp(y, x, :, r)), mean(squeeze(img_resp(y, x, :, 1:end ~= r)), 2));
        end
    end
end

save coherence_map.mat coherence_map

% 
% disp('Load your stimulus data...')
% [fn, pn] = uigetfile('*.mat');
% load([pn, fn])

cc_map = rot90(mean(coherence_map, 3));
%cc_map(VFS_boundaries) = max(cc_map(:)) * 1.1;
imagesc(cc_map)

%{
% compare against a shuffled control
n_iter = 100;
for iter = 1:n_iter
    fprintf('Iteration #%d / %d\n', iter, n_iter)
    for r = 1:size(img_resp, 4)
        shuffled(:, :, :, r) = circshift(img_resp(:, :, :, r), randi(size(img_resp, 3)), 3);
    end
    for y = 1:size(img_resp, 1)
        for x = 1:size(img_resp, 2)
            for r = 1:size(img_resp, 4)
>> s.rotate(0.1)
                shuffled_map(y, x, iter) = corr(squeeze(shuffled(y, x, :, r)), mean(squeeze(shuffled(y, x, :, 1:end ~= r)), 2));
            end
        end
    end
end
%}