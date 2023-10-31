function fin=roast_seg(subj,recipe,varargin)
% roast(subj,recipe,varargin)
%
% AJ modified ROAST 30/11/20
% This part just does the segmentation of the scan 
%
% For a published version of the manuscript above, use this as reference:
% Huang, Y., Datta, A., Bikson, M., Parra, L.C., ROAST: an open-source,
% fully-automated, Realistic vOlumetric-Approach-based Simulator for TES.
% Proceedings of the 40th Annual International Conference of the IEEE 
% Engineering in Medicine and Biology Society, Honolulu, HI, July 2018
% 
% If you use New York head to run simulation, please also cite the
% following:
% Huang, Y., Parra, L.C., Haufe, S.,2016. The New York Head - A precise
% standardized volume conductor model for EEG source localization and tES
% targeting. NeuroImage,140, 150-162
% 
% (c) Yu (Andy) Huang, Parra Lab at CCNY
% yhuang16@citymail.cuny.edu
% March 2019

addpath(genpath([fileparts(which(mfilename)) filesep 'lib/']));

fprintf('\n\n');
disp('======================================================')
disp('CHECKING INPUTS...')
disp('======================================================')
fprintf('\n');

% warning('on');

% check subject name
if nargin<1 || isempty(subj)
    subj = 'example/MNI152_T1_1mm.nii';
end

if strcmpi(subj,'nyhead')
    subj = 'example/nyhead.nii';
end

if ~strcmpi(subj,'example/nyhead.nii') && ~exist(subj,'file')
    error(['The subject MRI you provided ' subj ' does not exist.']);
end

if ~strcmpi(subj,'example/nyhead.nii')
    t1Data = load_untouch_nii(subj);
    if t1Data.hdr.hist.qoffset_x == 0 && t1Data.hdr.hist.srow_x(4)==0
        error('The MRI has a bad header. SPM cannot generate the segmentation properly for MRI with bad header. You can manually align the MRI in SPM Display function to fix the header.');
    end
    % check if bad MRI header
end


if ~exist('T2','var')
    T2 = [];
else
    if ~exist(T2,'file'), error(['The T2 MRI you provided ' T2 ' does not exist.']); end
    
    t2Data = load_untouch_nii(T2);
    if t2Data.hdr.hist.qoffset_x == 0 && t2Data.hdr.hist.srow_x(4)==0
        error('The MRI has a bad header. SPM cannot generate the segmentation properly for MRI with bad header. You can manually align the MRI in SPM Display function to fix the header.');
    end
    % check if bad MRI header    
end


% preprocess MRI data
if ~strcmpi(subj,'example/nyhead.nii') % only when it's not NY head

    if ~isempty(T2)
        T2 = realignT2(T2,subjRSPD);
    end
    % check if T2 is aligned with T1
    
else
    
    if ~exist('example/nyhead_T1orT2_masks.nii','file')
        unzip('example/nyhead_T1orT2_masks.nii.zip','example')
    end
    
    if doResamp
        error('The beauty of New York head is its 0.5 mm resolution. It''s a bad practice to resample it into 1 mm. Use another head ''example/MNI152_T1_1mm.nii'' for 1 mm model.');
    end
    
   
    if ~isempty(T2)
       warning('New York head selected. Any specified T2 image will be ignored.');
       T2 = [];
    end
        
end

configTxt = [];

options = struct('configTxt',configTxt,'T2',T2);

% log tracking
[dirname,baseFilename] = fileparts(subj);
if isempty(dirname), dirname = pwd; end

fprintf('\n\n');
disp('======================================================')
if ~strcmp(baseFilename,'nyhead')
    disp(['ROAST ' subj])
else
    disp('ROAST New York head')
end
disp('JUST THE SEGMENTATION:')
disp('AJ modified ROAST version for lesions')
disp('======================================================')
fprintf('\n\n');

if ~strcmp(baseFilename,'nyhead')
    
    [~,baseFilenameRSPD] = fileparts(subj);
    
    if (isempty(T2) && ~exist([dirname filesep 'c1' baseFilenameRSPD '_T1orT2.nii'],'file')) ||...
            (~isempty(T2) && ~exist([dirname filesep 'c1' baseFilenameRSPD '_T1andT2.nii'],'file'))
        disp('======================================================')
        disp('       STEP 1 (out of 6): SEGMENT THE MRI...          ')
        disp('======================================================')
        start_seg(subj,T2);
    else
        disp('======================================================')
        disp('          MRI ALREADY SEGMENTED, SKIP STEP 1          ')
        disp('======================================================')
    end
    
    if (isempty(T2) && ~exist([dirname filesep baseFilenameRSPD '_T1orT2_masks.nii'],'file')) ||...
            (~isempty(T2) && ~exist([dirname filesep baseFilenameRSPD '_T1andT2_masks.nii'],'file'))
        disp('======================================================')
        disp('     STEP 2 (out of 6): SEGMENTATION TOUCHUP...       ')
        disp('======================================================')
        segTouchup_seg(subj,T2);
    else
        disp('======================================================')
        disp('    SEGMENTATION TOUCHUP ALREADY DONE, SKIP STEP 2    ')
        disp('======================================================')
    end
    
else
    
    disp('======================================================')
    disp(' NEW YORK HEAD SELECTED, GOING TO STEP 3 DIRECTLY...  ')
    disp('======================================================')
    warning('New York head is a 0.5 mm model so is more computationally expensive. Make sure you have a decent machine (>32GB memory) to run ROAST with New York head.')
    [~,baseFilenameRSPD] = fileparts(subj);
    
end
fin='ROAST seg is DONE';