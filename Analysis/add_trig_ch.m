num_t_samples = size(y,2);
idx_to_use = 8000:num_t_samples-5000;
s = y(2:33,idx_to_use);
s_std = std(s, [], 2);
s_std_median = median(s_std);
s_average = mean(s,2);
s_average_median = median(s_average);
ch_idx = dsearchn(s_average, s_average_median);
num_t_samples = size(s,2);

trig_ch = zeros(num_t_samples,1);
w_size = 100; % time-points 
w_num = 1;
for t_idx = 1:w_size:num_t_samples-w_size
    s_cur = s(ch_idx, t_idx:t_idx+w_size-1);
    [max_val, max_idx] = max(s_cur);
    abs_max_idx = max_idx + w_size*(w_num-1);
    trig_ch(abs_max_idx-1:abs_max_idx+1) = 1;
    w_num = w_num + 1;
end

figure();
plot(s(ch_idx,:));
% dev1 = y(ch_idx,7000:end-3000) - s_average_median > s_std_median;
% dev2 = y(ch_idx,7000:end-3000) - s_average_median < -s_std_median;
% dev = dev1 | dev2;
hold on
plot(200*trig_ch)