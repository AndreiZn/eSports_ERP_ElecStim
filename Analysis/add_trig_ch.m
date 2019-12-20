data_root_folder = uigetdir('./','Select a data root folder...');
output_folder = uigetdir('./','Select an output folder...');

subject_folders = dir(data_root_folder);
subject_folders = subject_folders(3:end);

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        y = load(filepath); y = y.y;

        n_ch = size(y,1); % time channel first, and the rest is eeg channels
        eeg_channels = 2:n_ch;
        s = y(eeg_channels,:);
        num_t_samples = size(s,2);
        trig_ch = zeros(num_t_samples,1);
        
        % frequency of electostimulation was set to 5 Hz, but actually it worked at
        % 2.5 Hz
        freq_of_ES = 2.5; % Hz
        sample_rate = 250; % Hz
        % we will check windows of w_size width and find there a maximum peak -
        % at each channel; the peak occurs exactly at times when the ES was
        % applied; thus, this moments can be used as trigger timesl
        w_size = sample_rate/freq_of_ES; % time-points
        w_num = 1;
        
        for t_idx = 1:w_size:num_t_samples-w_size
            peak_time = zeros(numel(eeg_channels),1);
            for ch_idx = 1:numel(eeg_channels)
                s_cur = s(ch_idx, t_idx:t_idx+w_size-1);
                [max_val, max_idx] = max(s_cur);
                abs_max_idx = max_idx + w_size*(w_num-1);
                peak_time(ch_idx) = abs_max_idx;
            end
            [num_occurrences,elements]=hist(peak_time,unique(peak_time));
            [max_num_occ, elem_idx] = max(num_occurrences);
            abs_max_idx = elements(elem_idx);
            trig_ch(abs_max_idx:abs_max_idx+1) = 1;
            w_num = w_num + 1;
        end
        
%         figure();
%         plot(s(ch_idx,:));
%         hold on
%         plot(150*trig_ch)
        
        y_out = zeros(n_ch+3, num_t_samples);
        y_out(1:n_ch, :) = y(:, :);
        % record the trigger channel to y_out(34:36,:), because typical
        % signal in other experiments also contains channels 34:36 
        y_out(n_ch+1, :) = trig_ch';
        y_out(n_ch+2, :) = trig_ch';
        y_out(n_ch+3, :) = trig_ch';

        y = y_out; 
        
        % build the filename appropriate for the further pipeline
        filename = file_struct.name(1:8); %sub****_'
        num_recorded_ch = str2double(file_struct.name(12));
        if num_recorded_ch == 3
            filename = [filename, '32'];
        elseif num_recorded_ch == 8
            filename = [filename, '08'];
        else
            errordlg('cannot parse num channels from the filename')
        end
        
        used_freq = str2double(file_struct.name(end-8));
        if used_freq == 5
            filename = [filename, '_5'];
        elseif used_freq == 1
            filename = [filename, '_1'];
        else
            errordlg('cannot parse ES frequency from the filename')
        end
        
        finger = file_struct.name(end-4);
        if strcmp(finger, 'L')
            filename = [filename, 'L'];
        elseif strcmp(finger, 'R')
            filename = [filename, 'R'];
        else
            errordlg('cannot parse from the filename if L or R finger was used during the recording')
        end
        
        output_folder_cur = [output_folder, '\', subj_folder.name];
        if ~exist(output_folder_cur, 'dir')
            mkdir(output_folder_cur)
        end
        save([output_folder_cur, '\', filename], 'y')
    end
end