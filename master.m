load('DFF.mat')
p = Processor(DFF);
p.sortData();

resp_matrix = p.getProcessedData();
keyboard
% mean across repeats
% img_resp = squeeze(mean(resp_matrix, 3));

for y = 1:size(img_resp, 1)
    for x = 1:size(img_resp, 2)
        for r = 1:size(img_resp, 4)
            map(y, x) = corr(squeeze(img_resp(y, x, :, r)), mean(squeeze(img_resp(y, x, :, 1:end ~= r)), 2));
        end
    end
end


cc_map = rot90(map);
cc_map(VFS_boundaries) = max(cc_map(:)) * 1.1;
imagesc(cc_map)


% compare against a shuffled control
n_iter = 100;
for iter = 1:n_iter
    fprintf('Iteration #%d / %d\n', iter, n_iter)
    for r = 1:size(resp_matrix, 5)
        shuffled(:, :, :, :, r) = resp_matrix(:, :, :, randperm(size(resp_matrix, 4)), r);
    end
    img_resp = reshape(shuffled, 400, 400, [], 5);
    for y = 1:size(img_resp, 1)
        for x = 1:size(img_resp, 2)
            for r = 1:size(img_resp, 4)
                shuffled_map(y, x, iter) = corr(squeeze(img_resp(y, x, :, r)), mean(squeeze(img_resp(y, x, :, 1:end ~= r)), 2));
            end
        end
    end
end
