function opt = osl_check_opt(optin)

% opt = osl_check_opt(opt)
%
% See https://ohba-analysis.github.io/osl-docs/pages/docs/opt.html for
% documentation on OPT
%
% Checks an OPT (OSL's Preprocessing Tool) struct has all the appropriate
% settings, which can then be passed to osl_run_opt to do an OPT
% analysis. Throws an error if any required inputs are missing, fills other
% settings with default values.
%
% Required inputs:
%
% opt.spm_files: A list of the spm meeg files for input into SPM (require
% .mat extensions).
% e.g.:
% spm_files{1}=[testdir '/spm_files/sub1.mat'];
% spm_files{2}=[testdir '/spm_files/sub2.mat'];
% etc...
%
% AND:
%
% opt.datatype: Specifies the datatype, i.e. 'neuromag', 'ctf', 'eeg'
% e.g. opt.datatype='neuromag';
%
% Optional inputs:
%
% See inside this function (e.g. use "type osl_check_opt") to see the other
% optional settings, or just look at the fields in the output opt!
%
% MWW 2013

opt=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% required inputs

try opt.datatype=optin.datatype; optin = rmfield(optin,'datatype'); catch, error('Need to specify opt.datatype'); end % datatype: 'neuromag', 'ctf', 'eeg'

try opt.spm_files=optin.spm_files; optin = rmfield(optin,'spm_files'); catch, opt.spm_files=[]; end % Specify a list of the SPM MEEG files 

num_sessions=length(opt.spm_files);

% check that full directory names have been specified
for iSess = 1:num_sessions
    sessPath = fileparts(opt.spm_files{iSess});
    if isempty(sessPath) || strcmpi(sessPath(1), '.')
        error([mfilename ':FullPathNotSpecified'], ...
              'Please specify full paths for the fif, input or spm files. \n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% optional settings:

try opt.sessions_to_do=optin.sessions_to_do; optin = rmfield(optin,'sessions_to_do'); catch, opt.sessions_to_do=1:num_sessions; end

try opt.dirname=optin.dirname; optin = rmfield(optin,'dirname'); catch, opt.dirname=[sess{1} '.opt']; end % directory name which will be created and within which all results associated with this source recon will be stored
if(isempty(findstr(opt.dirname, '.opt')))
    opt.dirname=[opt.dirname, '.opt'];
end

try opt.modalities=optin.modalities; optin = rmfield(optin,'modalities');
catch,
    switch opt.datatype
        case 'neuromag'
            opt.modalities={'MEGMAG';'MEGPLANAR'};
        case 'ctf'
            opt.modalities={'MEGGRAD'};
        case 'eeg'
            opt.modalities={'EEG'};
    end
end

% flag to indicate whether SPM files generated by opt stages other than the
% final one should be cleaned up as the pipeline progresses. A value of 0 means
% nothing will be deleted, 1 means most files will be deleted (apart from
% post-sss fif and pre/post africa files) and 2 means that everything will be
% cleaned up
try opt.cleanup_files=optin.cleanup_files; optin = rmfield(optin,'cleanup_files'); catch, opt.cleanup_files=1; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% downsample settings

try opt.downsample.do=optin.downsample.do; optin.downsample = rmfield(optin.downsample,'do'); catch, opt.downsample.do=1; end % flag to do or not do downsample
try opt.downsample.freq=optin.downsample.freq; optin.downsample = rmfield(optin.downsample,'freq'); catch, opt.downsample.freq=250; end % downsample freq in Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% highpass settings

try opt.highpass.do=optin.highpass.do; optin.highpass = rmfield(optin.highpass,'do'); catch, opt.highpass.do=0; end % flag to indicate if high pass filtering should be done 
try opt.highpass.cutoff=optin.highpass.cutoff; optin.highpass = rmfield(optin.highpass,'cutoff'); catch, opt.highpass.cutoff=0.1; end % highpass cutoff in Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mains settings

try opt.mains.do=optin.mains.do; optin.mains = rmfield(optin.mains,'do'); catch, opt.mains.do=0; end % flag to indicate if mains filtering should be done 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% spectograms settings

try opt.spectograms.do=optin.spectograms.do; optin.spectograms = rmfield(optin.spectograms,'do'); catch, opt.spectograms.do=0; end % flag to indicate if spectogram is plotted 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% trial and chan outlier detection settings

try opt.bad_segments.do=optin.bad_segments.do; optin.bad_segments = rmfield(optin.bad_segments,'do'); catch, opt.bad_segments.do=1; end % flag to indicate if bad_segment marking should be done
try opt.bad_segments.dummy_epoch_tsize=optin.bad_segments.dummy_epoch_tsize; optin.bad_segments = rmfield(optin.bad_segments,'dummy_epoch_tsize'); catch, opt.bad_segments.dummy_epoch_tsize=2; end % size of dummy epochs (in secs) to do outlier bad segment marking
try opt.bad_segments.outlier_measure_fns=optin.bad_segments.outlier_measure_fns; optin.bad_segments = rmfield(optin.bad_segments,'outlier_measure_fns'); catch, opt.bad_segments.outlier_measure_fns={'std'}; end % list of outlier metric func names to use for bad segment marking
try opt.bad_segments.event_significance=optin.bad_segments.event_significance; optin.bad_segments = rmfield(optin.bad_segments,'event_significance'); catch, opt.bad_segments.event_significance=0.05; end 
try opt.bad_segments.channel_significance=optin.bad_segments.channel_significance; optin.bad_segments = rmfield(optin.bad_segments,'channel_significance'); catch, opt.bad_segments.channel_significance=0.05; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% africa settings

try do_africa=optin.africa.do; optin.africa = rmfield(optin.africa,'do'); catch, do_africa=false; end % flag to do or not do africa
try opt.africa.todo.ica=optin.africa.todo.ica; optin.africa.todo = rmfield(optin.africa.todo,'ica'); catch, opt.africa.todo.ica=do_africa; end % flag to do or not do ica decomposition
try opt.africa.todo.ident=optin.africa.todo.ident; optin.africa.todo = rmfield(optin.africa.todo,'ident'); catch, opt.africa.todo.ident=do_africa; end % flag to do or not do artefact rejection
try opt.africa.todo.remove=optin.africa.todo.remove; optin.africa.todo = rmfield(optin.africa.todo,'remove'); catch, opt.africa.todo.remove=do_africa; end % flag to do or not do artefactual component removal
try opt.africa.precompute_topos=optin.africa.precompute_topos; optin.africa = rmfield(optin.africa,'precompute_topos'); catch, opt.africa.precompute_topos=1; end % flag to do or not do precomputation of topos of IC spatial maps after ica has been computed for future use in ident
try opt.africa.used_maxfilter=optin.africa.used_maxfilter; optin.africa = rmfield(optin.africa,'used_maxfilter');
catch,
    switch opt.datatype
        case 'neuromag'
            opt.africa.used_maxfilter=1;
        otherwise
            opt.africa.used_maxfilter=0;
    end
end % flag to indicate if SSS Maxfilter has been done
if do_africa
    warning('Automated aretafact identification in AFRICA is currently only a beta release and is not recommended. Either turn it off, or use manual AFRICA instead');
end

% africa.ident settings (used in identifying which artefacts are bad):
opt.africa.ident=[];
try opt.africa.ident.artefact_chans=optin.africa.ident.artefact_chans; optin.africa.ident = rmfield(optin.africa.ident,'artefact_chans'); catch, opt.africa.ident.artefact_chans={'ECG','EOG'}; end % list of names of artefact channels
try opt.africa.ident.artefact_chans_corr_thresh=optin.africa.ident.artefact_chans_corr_thresh; optin.africa.ident = rmfield(optin.africa.ident,'artefact_chans_corr_thresh'); catch, opt.africa.ident.artefact_chans_corr_thresh=0.15; end % vector setting the correlation threshold to use for each of the artefact chans
try opt.africa.ident.do_kurt=optin.africa.ident.do_kurt; optin.africa.ident = rmfield(optin.africa.ident,'do_kurt'); catch, opt.africa.ident.do_kurt=1; end % flag to do detection of bad ICA components based on high kurtosis
try opt.africa.ident.kurtosis_wthresh=optin.africa.ident.kurtosis_wthresh; optin.africa.ident = rmfield(optin.africa.ident,'kurtosis_wthresh'); catch, opt.africa.ident.kurtosis_wthresh=0.4; end % threshold to use on robust GLM weights. Set to zero to not use. Set between 0 and 1, where a value closer to 1 gives more aggressive rejection
try opt.africa.ident.kurtosis_thresh=optin.africa.ident.kurtosis_thresh; optin.africa.ident = rmfield(optin.africa.ident,'kurtosis_thresh'); catch, opt.africa.ident.kurtosis_thresh=0; end % threshold to use on kurtosis. Set to zero to not use. Both the thresh and wthresh conditions must be met to reject 
try opt.africa.ident.do_mains=optin.africa.ident.do_mains; optin.africa.ident = rmfield(optin.africa.ident,'do_mains'); catch, opt.africa.ident.do_mains=1; end % flag to indicate whether or not mains component should be looked for
try opt.africa.ident.mains_frequency=optin.africa.ident.mains_frequency; optin.africa.ident = rmfield(optin.africa.ident,'mains_frequency'); catch, opt.africa.ident.mains_frequency=50; end % mains freq in Hz
try opt.africa.ident.mains_kurt_thresh=optin.africa.ident.mains_kurt_thresh; optin.africa.ident = rmfield(optin.africa.ident,'mains_kurt_thresh'); catch, opt.africa.ident.mains_kurt_thresh=0.2; end % mains kurtosis threshold (below which Mains IC must be)
try opt.africa.ident.func=optin.africa.ident.func; optin.africa.ident = rmfield(optin.africa.ident,'func'); catch, opt.africa.ident.func=@identify_artefactual_components_auto; end % function pointer to artefact detection algorithm
try opt.africa.ident.max_num_artefact_comps=optin.africa.ident.max_num_artefact_comps; optin.africa.ident = rmfield(optin.africa.ident,'max_num_artefact_comps'); catch, opt.africa.ident.max_num_artefact_comps=10; end % max number of components that will be allowed to be labelled as bad in each category

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% epoch settings

try opt.epoch.do=optin.epoch.do; optin.epoch = rmfield(optin.epoch,'do'); catch, opt.epoch.do=1; end % flag to indicate if epoching should be done
try opt.epoch.time_range=optin.epoch.time_range; optin.epoch = rmfield(optin.epoch,'time_range'); catch, opt.epoch.time_range=[0.5 2]; end % epoch time range
try opt.epoch.timing_delay=optin.epoch.timing_delay; optin.epoch = rmfield(optin.epoch,'timing_delay'); catch, opt.epoch.timing_delay=0; end % time delay adjustment (e.g. due to delay in visual presentations) in secs
try opt.epoch.trialdef=optin.epoch.trialdef; optin.epoch = rmfield(optin.epoch,'trialdef'); catch, opt.epoch.trialdef=1; end
% trialdef, e.g.:
%opt.epoch.trialdef(1).conditionlabel = 'StimLRespL';
%opt.epoch.trialdef(1).eventtype = 'STI101_down';
%opt.epoch.trialdef(1).eventvalue = 11;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% trial and chan outlier detection settings

try opt.outliers.do=optin.outliers.do; optin.outliers = rmfield(optin.outliers,'do'); catch, opt.outliers.do=1; end % flag to indicate if outliersing should be done
try opt.outliers.outlier_measure_fns=optin.outliers.outlier_measure_fns; optin.outliers = rmfield(optin.outliers,'outlier_measure_fns'); catch, opt.outliers.outlier_measure_fns={'min','std'}; end % list of outlier metric func names to use
try opt.outliers.event_significance=optin.outliers.event_significance; optin.outliers = rmfield(optin.outliers,'event_significance'); catch, opt.outliers.event_significance=0.05; end 
try opt.outliers.channel_significance=optin.outliers.channel_significance; optin.outliers = rmfield(optin.outliers,'channel_significance'); catch, opt.outliers.channel_significance=0.05; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% coreg settings

try opt.coreg.do=optin.coreg.do; optin.coreg = rmfield(optin.coreg,'do'); catch, opt.coreg.do=1; end % flag to do or not do downsample
try opt.coreg.useheadshape = optin.coreg.useheadshape; optin.coreg = rmfield(optin.coreg,'useheadshape'); catch, opt.coreg.useheadshape=1; end
try opt.coreg.mri = optin.coreg.mri; optin.coreg = rmfield(optin.coreg,'mri'); catch, for i=1:num_sessions, opt.coreg.mri{i}=''; end, end
try opt.coreg.use_rhino = optin.coreg.use_rhino; optin.coreg = rmfield(optin.coreg,'use_rhino'); catch, opt.coreg.use_rhino = 1; end % Use RHINO coregistration
try opt.coreg.forward_meg = optin.coreg.forward_meg; optin.coreg = rmfield(optin.coreg,'forward_meg'); catch, opt.coreg.forward_meg = 'Single Shell'; end % MEG forward model, typically either 'MEG Local Spheres' or 'Single Shell'
try opt.coreg.fid_label = optin.coreg.fid_label; optin.coreg = rmfield(optin.coreg,'fid_label');    
catch
    switch opt.datatype
        case 'neuromag'
            opt.coreg.fid_label.nasion='Nasion'; opt.coreg.fid_label.lpa='LPA'; opt.coreg.fid_label.rpa='RPA';
        case 'ctf'
            opt.coreg.fid_label.nasion='nas'; opt.coreg.fid_label.lpa='lpa'; opt.coreg.fid_label.rpa='rpa';
        case 'eeg'
            opt.coreg.fid_label.nasion='Nasion'; opt.coreg.fid_label.lpa='LPA'; opt.coreg.fid_label.rpa='RPA';
        otherwise
            opt.coreg.fid_label=[];
    end
end % To see what these should be look at: D.fiducials.fid.label



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% copy any results
try opt.results=optin.results;
    optin = rmfield(optin,'results'); catch, end
try opt.date=optin.date; optin = rmfield(optin,'date'); catch, end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check people haven't set any wierd fields
if isfield(optin,'epoch')
wierdfields = fieldnames(optin.epoch);
if ~isempty(wierdfields)
    disp('The following opt.epoch settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');
end % if ~isempty(wierdfields)
end

if isfield(optin,'outliers')
wierdfields = fieldnames(optin.outliers);
if ~isempty(wierdfields)
    disp('The following opt.outliers settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');
end % if ~isempty(wierdfields)
end

if isfield(optin,'bad_segments')
wierdfields = fieldnames(optin.bad_segments);
if ~isempty(wierdfields)
    disp('The following opt.bad_segments settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');
end % if ~isempty(wierdfields)
end

if isfield(optin,'highpass')
wierdfields = fieldnames(optin.highpass);
if ~isempty(wierdfields)
    disp('The following opt.highpass settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');

end % if ~isempty(wierdfields)
end

if isfield(optin,'mains')
wierdfields = fieldnames(optin.mains);
if ~isempty(wierdfields)
    disp('The following opt.mains settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');

end % if ~isempty(wierdfields)
end

if isfield(optin,'spectograms')
wierdfields = fieldnames(optin.spectograms);
if ~isempty(wierdfields)
    disp('The following opt.spectograms settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');

end % if ~isempty(wierdfields)
end

if isfield(optin,'downsample')
wierdfields = fieldnames(optin.downsample);
if ~isempty(wierdfields)
    disp('The following opt.downsample settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');

end % if ~isempty(wierdfields)
end

try optin.coreg = rmfield(optin.coreg,'fid_label');catch, end
if isfield(optin,'coreg'),
wierdfields = fieldnames(optin.coreg);
if ~isempty(wierdfields)
    disp('The following opt.coreg settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');
end % if ~isempty(wierdfields)
end

try optin.africa = rmfield(optin.africa,'ident');catch, end
try optin.africa = rmfield(optin.africa,'todo');catch, end
if isfield(optin,'africa'),
wierdfields = fieldnames(optin.africa);
if ~isempty(wierdfields)
    disp('The following opt.africa settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');

end % if ~isempty(wierdfields)
end

%try optin = rmfield(optin,'osl_version');catch, end
try optin = rmfield(optin,'osl2_version');catch, end
try optin = rmfield(optin,'epoch');catch, end
try optin = rmfield(optin,'outliers');catch, end
try optin = rmfield(optin,'bad_segments');catch, end
try optin = rmfield(optin,'highpass');catch, end
try optin = rmfield(optin,'mains');catch, end
try optin = rmfield(optin,'spectograms');catch, end
try optin = rmfield(optin,'downsample');catch, end
try optin = rmfield(optin,'coreg');catch, end
try optin = rmfield(optin,'africa');catch, end
try optin = rmfield(optin,'fname'); catch, end


wierdfields = fieldnames(optin);
if ~isempty(wierdfields)
    disp('The following opt settings were not recognized by osl_check_opt');

    for iprint = 1:numel(wierdfields)
        disp([' ' wierdfields{iprint} ' '])
    end
    error('Invalid osl_check_opt settings');
end % if ~isempty(wierdfields)

%% add osl version
opt.osl2_version=osl_version;

