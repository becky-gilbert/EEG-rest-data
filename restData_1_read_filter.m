% Gareth and Michael's EEG rest data analysis

% Step 1

% -Load in the raw data ('Traces.edf')
% -Add channel locations
% -Remove the DC offset
% -Save the data (e.g. 's1_step1.set')

% -Load in the data from previous loop (e.g. 's1_step1.set')
% -Remove unnecessary channels
% -Check that the channel order is consistent across data sets
% -Save the data (e.g. 's1_step1_chan.set')

% -Load in the data from previous loop (e.g. 's1_step1_chan.set')
% -Highpass filter
% -Save the data (e.g. 's1_step1_chan_hpf.set')

% Becky Gilbert, Oct 2014


% Define subject set - these names are insane...
subjects = {'02RFS_06ece715-ff14-42c2-b216-2f56d2e4a73d',...
    '05RFS_db0155a0-facb-4a13-824c-5e63c3b95f7d',...
    '08RFS_6d3104d3-4f18-41b0-9725-fc82ef5344a1',...
    '11RFS_789e3570-1d40-4675-89c8-8c753fdd94a3',...
    '14RSF_a755c303-b9c8-4dd3-a4e9-d7dcd2846015',...
    '17RFS_54ac4843-7773-4a16-96b9-04a2df72bdc1',...
    '20RFS_fc79eefd-5b21-4235-b4ce-6dd0b6b55103',...
    '23RFS_b5b6158f-5b32-4b2a-a2c4-637b15ef4816'};
nSubj = length(subjects);

% Set paths to folder containing the data files and folder to save output data
filePathIn = '/home/rebeccagilbert/Documents/EEG_data_rest/Rest_study/';
filePathOut = '/home/rebeccagilbert/Documents/EEG_data_rest/Rest-data-analysis/EEG-rest-data/';


for s = 1:nSubj
    
    fprintf('\n\n****** Processing subject number %d ******\n\n', s);
    
    % Get current subject file
    sname = [filePathIn subjects{s} '/Traces.edf'];
    
    if exist(sname, 'file') <= 0
        
        fprintf('\n *** WARNING: Subject %d does not exist *** \n', s);
        fprintf('\n *** Skip all processing for this subject *** \n');
        
    else
        
        % Load raw edf data
        fprintf('\n\n**** Subject number %d: Loading dataset ****\n\n', s);
        EEG = pop_biosig(sname);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', ['s' num2str(s)], 'gui', 'off');
        EEG = eeg_checkset(EEG);
        EEG = eeg_checkset(EEG);
        
        % Add channel locations
        fprintf('\n\n**** Subject number %d: Adding channel location info ****\n\n', s);
        EEG = pop_chanedit(EEG, 'lookup','/home/rebeccagilbert/bin/eeglab11_0_4_3b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
        EEG = eeg_checkset(EEG);
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Create eventlist
        %fprintf('\n\n**** Subject %s: Creating eventlist ****\n\n', subjects{s});
        %EEG = pop_editeventlist(EEG, [filePath 'eventEquationList.txt'], [filePath 's' subjects{s} '_eventlist.txt'], {'boundary'}, {-99});
        
        % Remove DC offset - empty brackets indicates all times/points
        EEG = pop_rmbase(EEG, []);
        EEG = eeg_checkset(EEG);
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Save new data set
        fprintf('\n\n**** Subject %d: Saving data set ****\n\n', s);
        EEG.setname = [EEG.setname '_step1'];
        EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', filePathOut);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Remove current data set from memory
        ALLEEG = pop_delset(ALLEEG, CURRENTSET);
        
    end
end
fprintf('\n\n**** FINISHED ****\n\n');


% Remove non-EEG channels from the data and check channel order

chansToKeep = {'E1', 'E2', 'M1', 'C3', 'C4', 'M2', 'O1', 'O2', 'F3', 'F4'};
chansToRemove = {'ChinR', 'ChinL', 'Light_CU', 'Gravity X', 'Gravity Y', 'Activity_CU', 'Elevation_CU'};

for s = 1:nSubj
    
    sname = ['s' s '_step1.set'];
    
    fprintf('\n\n**** Subject %d: Loading dataset ****\n\n', s);
    EEG = pop_loadset('filename', sname);
    
    fprintf('\n\n**** Subject %d: %d channels in original data set ****\n\n', s, EEG.nbchan);
    
    % Get channel numbers and labels
    chanLocsCell = squeeze(struct2cell(EEG.chanlocs));
    chanLabels = [chanLocsCell(1,1:end)]';
    % STOPPED HERE 
    
    fprintf('\n\n**** Subject %d: %d channels in modified data set ****\n\n', s, EEG.nbchan);
    
    % Save new data set
    fprintf('\n\n\n**** Subject %d: Saving data set ****\n\n\n', s);
    EEG.setname = [EEG.setname '_chans'];
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [EEG.setname '.set'], 'gui', 'off');
end


% Highpass filter at .04 Hz (what value do we want?)
highpassFilterValue = 0.04;
for s = 1:nSubj
    
    sname = ['s' s '_step1_chans.set'];
    
    fprintf('\n\n**** Subject %d: Loading dataset ****\n\n', s);
    EEG = pop_loadset('filename', sname);
    
    % Filter the continuous data (to avoid boundary artifacts)
    fprintf('\n\n**** Subject %d: Creating eventlist ****\n\n', s);
    EEG = pop_eegfilt(EEG, highpassFilterValue, 0, [], [0], 0, 0, 'fir1', 0);
    
    % Save new data set
    fprintf('\n\n**** Subject %d: Saving data set ****\n\n', s);
    EEG.setname = [EEG.setname '_hpf'];
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [EEG.setname '.set'], 'gui', 'off');
    
end


