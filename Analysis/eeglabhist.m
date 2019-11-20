root_folder = 'E:\Electrical_stimulation_exp\Electrical_stimulation_exp_data';

files = dir(root_folder);
files_flag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
files = files(files_flag);

for filei=1:numel(files)
    
    % read file
    file_struct = files(filei);
    filepath = fullfile(file_struct.folder, file_struct.name);
    
    EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',filepath,'setname',file_struct.name,'srate',500,'pnts',0,'xmin',0);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_select( EEG,'channel',[2:9]);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_editset(EEG, 'chanlocs', 'E:\\EEG_caps_comparison_main\\EEG_caps_comparison_code\\eeglab14_1_2b\\sample_locs\\gGAMMAcap8ch_10-20.locs');
    EEG = eeg_checkset( EEG );
        
    EEG = eeg_eegrej( EEG, [0 7000]);
    EEG = eeg_checkset( EEG );
    
    CFG.time_step_to_plot = 5;
    fig = Plot_EEG_data(EEG, CFG);
    saveas(fig, [file_struct.folder, file_struct.name, '_dataplot', '.png'])
    close(fig)
    
    figure; pop_spectopo(EEG, 1, [0 1000*EEG.xmax], 'EEG' , 'freq', [5 10 20 40], 'freqrange',[1 50],'electrodes','off');
    saveas(gcf, [file_struct.folder, file_struct.name, '_spectopoplot', '.png'])
    close(gcf)
    
end



