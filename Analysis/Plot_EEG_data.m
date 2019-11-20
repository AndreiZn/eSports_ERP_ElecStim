function fig = Plot_EEG_data(EEG, CFG)
srate = EEG.srate;
regular_spacing = max(mean(EEG.data,2) + 6*std(EEG.data,[],2));
extreme_case_spacing = 1000; % microvolts
spacing = min([regular_spacing, extreme_case_spacing]);
eegplot('noui', EEG.data, 'winlength', size(EEG.data,2)/srate, 'srate', srate, 'spacing', spacing);
fig = gcf;
chldrn = fig.Children;
ax_idx = 4; % usually works, but unstable
for i=1:numel(chldrn)
    if isa(chldrn(i),'matlab.graphics.axis.Axes') && ~isempty(chldrn(i).UserData)
        ax_idx = i;
    end
end
ax = chldrn(ax_idx);
xticks(ax, 0:srate*CFG.time_step_to_plot:size(EEG.data,2));
xticklabels(ax, 0:CFG.time_step_to_plot:size(EEG.data,2)/srate);
yt = get(ax, 'YTick');
yt = yt(2:end);
set(ax, 'YTick', yt);
ch_labels = {EEG.chanlocs.labels};
set(ax, 'YTickLabel', fliplr(ch_labels));
grid on;
% saveas(fig,[conf.output_dir, '\', conf.subject,'_',conf.curr_dev,'_', conf.exp_num, '_plot','.png'])
% close(gcf)