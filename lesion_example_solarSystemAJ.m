%% Stroke lesion ROAST processing example
% Ainslie Johnstone
% 30.11.20


%% Setting up the parameters
% Assuming each subject T1 is in its own folder within the ROAST_lesion
% folder. RAS format
clear all; close all
subj=('subjectAJ');
subj_T1=strcat(subj,'/',subj,'.nii');
ROAST_dir=('../../Volumes/AJ_DRIVE/ROAST_lesion/');%change for other computers

montage= {'Exx20',-1,'FFT7h',1};    %M1 {'Fp2',-1,'CCP3',1};BA44 {'Exx20',-1,'FFT7h',1}
elecsize=[17 2];

ROIcentre=[161,142,103];       %M1=[140,90,142]; BA44= [161,142,103];
ROIradius=10;
ROIname='BA44';

lesion_radius=[4,12,24]; % In voxels
lesion_dist=[1,5,10]; %how far away is the lesion
lesion_conduct=[0.6, 1, 1.4, 0.2, 1.8]; % Lesion conductance in S/m


%% Make the ROI mask

cd (['~/',ROAST_dir])
c1=niftiread(strcat(subj,'/c1',subj,'_T1orT2.nii'));
empty=zeros(size(c1,1), size(c1,2), size(c1,3));
info=niftiinfo(strcat(subj,'/c1',subj,'_T1orT2.nii'));

ROI_file=strcat(subj,'_' ,ROIname,'_ROI');
empty(ROIcentre(1), ROIcentre(2), ROIcentre(3))=1;
R=bwdist(empty);
ROI_mask=uint8(R<=ROIradius);

cd(['~/',ROAST_dir,'/',subj])
info.Filename=strcat(ROAST_dir,'/',subj,'/', ROI_file,'.nii');
niftiwrite(ROI_mask, ROI_file, info);

%% Set up subject and segmentation
% Running a modified ROAST of just segmentation
%addpath(['~/',ROAST_dir])
%cd (['~/',ROAST_dir])

% Run the segmentation only. Assuming these are already in RAS orientation,
% no resampling, and no zeropadding (this can be changed, but I find
% it messes up the positioning of the outputs)
% No other aspects of recipe are used, except T2 if we have it...
%fin=roast_seg(subj_T1);
%disp(fin)

%% Run a ROAST simulation as normal to get an 'no lesion' condition
% You could also run this to get the segmented images, but would then just
% have to change the names of the outputs
addpath(['~/',ROAST_dir])
cd (['~/',ROAST_dir])

% Run ROAST as normal on the 'healthy' brain
% Important to set the unique tag
%roast(subj_T1,montage,'simulationtag', 'healthy','elecSize', elecsize)

%% Edit the segmentation to add the lesion site
cd (['~/',ROAST_dir])

% Loading in all of the masks
c1=niftiread(strcat(subj,'/c1',subj,'_T1orT2.nii'));
info=niftiinfo(strcat(subj,'/c1',subj,'_T1orT2.nii'));

c2=niftiread(strcat(subj,'/c2',subj,'_T1orT2.nii'));
c3=niftiread(strcat(subj,'/c3',subj,'_T1orT2.nii'));
c4=niftiread(strcat(subj,'/c4',subj,'_T1orT2.nii'));
c5=niftiread(strcat(subj,'/c5',subj,'_T1orT2.nii'));
c6=niftiread(strcat(subj,'/c6',subj,'_T1orT2.nii'));
allMasks=niftiread(strcat(subj,'/',subj,'_T1orT2_masks.nii'));
thisT1=niftiread(subj_T1);

for radloop=1:length(lesion_radius)
    this_radius=lesion_radius(radloop);
    
    for distloop=1:length(lesion_dist)
        this_dist=lesion_dist(distloop);
        for moveDir=1:7
            for posneg=[1, -1]
                if moveDir==1 && posneg==-1
                    thisSDir='R';
                elseif moveDir==1 && posneg==1
                    thisSDir='L';
                elseif moveDir==2 && posneg==1
                    thisSDir='A';
                elseif moveDir==2 && posneg==-1
                    thisSDir='P';
                elseif moveDir==3 && posneg==1
                    thisSDir='S';
                elseif moveDir==3 && posneg==-1
                    thisSDir='I';
                elseif moveDir==4 && posneg==-1
                    thisSDir='RAS'; thisPosNeg=[-1, 1, 1];
                elseif moveDir==4 && posneg==1
                    thisSDir='LAS'; thisPosNeg=[ 1, 1, 1];
                elseif moveDir==5 && posneg==-1
                    thisSDir='RPS'; thisPosNeg=[-1,-1, 1];
                elseif moveDir==5 && posneg==1
                    thisSDir='LPS'; thisPosNeg=[ 1,-1, 1];
                elseif moveDir==6 && posneg==-1
                    thisSDir='RAI'; thisPosNeg=[-1, 1,-1];
                elseif moveDir==6 && posneg==1
                    thisSDir='LAI'; thisPosNeg=[ 1, 1,-1];
                elseif moveDir==7 && posneg==-1
                    thisSDir='RPI'; thisPosNeg=[-1,-1,-1];
                elseif moveDir==7 && posneg==1
                    thisSDir='LPI'; thisPosNeg=[ 1,-1,-1];
                end
                cd (['~/',ROAST_dir])
                
                LESIONtag=strcat(thisSDir,num2str(this_dist),'_sz',num2str(this_radius));
                
                
                if moveDir<4
                    lesion_centre=ROIcentre;
                    lesion_centre(moveDir)=ROIcentre(moveDir)+((ROIradius+this_dist+this_radius)*posneg);
                    empty=zeros(size(c1,1), size(c1,2), size(c1,3));
                    empty(lesion_centre(1), lesion_centre(2), lesion_centre(3))=1;
                    
                else
                    opposite=round(sqrt(((ROIradius+this_dist+this_radius)^2)/3));
                    lesion_centre=ROIcentre+(opposite*thisPosNeg);
                    empty=zeros(size(c1,1), size(c1,2), size(c1,3));
                    empty(lesion_centre(1), lesion_centre(2), lesion_centre(3))=1;
                end
                
                
                if allMasks(lesion_centre(1), lesion_centre(2), lesion_centre(3))<4 && allMasks(lesion_centre(1), lesion_centre(2), lesion_centre(3))>=1
                    
                    if not(isfile(strcat(subj,'/c1',subj,'_',LESIONtag,'_T1orT2.nii')))
                        
                        R=bwdist(empty);
                        lesion_mask=uint8(R<=this_radius);
                        
                        % Altering all the masks
                        c1_new=c1-lesion_mask*255; c2_new=c2-lesion_mask*255; c3_new=c3;
                        c4_new=c4; c5_new=c5; c6_new=c6;
                        
                        brain_lesion=(single(lesion_mask).*(single(c1)/255))+(single(lesion_mask).*(single(c2)/255));
                        c7_new=uint8(brain_lesion*255);
                        brain_lesion=single(brain_lesion>0.7);
                        inv_lesion=uint8(abs(brain_lesion-1));
                        allMasks_new=(allMasks.*inv_lesion)+uint8(brain_lesion*7);
                        thisT1_new=thisT1- int16(lesion_mask)*100;
                        
                        cd(subj)
                        
                        % Saving all of the new masks
                        thisFileName=strcat('c1',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c1_new, thisFileName, info);
                        thisFileName=strcat('c2',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c2_new, thisFileName, info);
                        thisFileName=strcat('c3',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c3_new, thisFileName, info);
                        thisFileName=strcat('c4',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c4_new, thisFileName, info);
                        thisFileName=strcat('c5',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c5_new, thisFileName, info);
                        thisFileName=strcat('c6',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c6_new, thisFileName, info);
                        thisFileName=strcat('c7',subj,'_',LESIONtag,'_T1orT2.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(c7_new, thisFileName, info);
                        
                        thisFileName=strcat(subj,'_',LESIONtag,'_T1orT2_masks.nii');
                        info.Filename=strcat(ROAST_dir,'/',subj,'/', thisFileName);
                        niftiwrite(allMasks_new, thisFileName, info);
                        
                        T1info=niftiinfo(subj_T1);
                        T1LesionName=strcat(subj,'_',LESIONtag,'.nii');
                        T1info.Filename=strcat(ROAST_dir,'/',subj,'/', T1LesionName);
                        niftiwrite(thisT1_new, T1LesionName, T1info);
                        
                        load(strcat(subj,'_T1orT2_rmask.mat'));
                        save(strcat(subj,'_',LESIONtag,'_T1orT2_rmask.mat'), 'eyes_vol', 'holes_vol', 'WMexclude_vol');
                        
                        load(strcat(subj,'_T1orT2_seg8.mat'));
                        image.fname=strcat(ROAST_dir,'/',subj,'/', T1LesionName);
                        save(strcat(subj,'_',LESIONtag,'_T1orT2_seg8.mat'), 'Affine', 'image', 'lkp', 'll', 'mg',...
                            'mn', 'MT', 'Tbias', 'tpm', 'Twarp', 'vr', 'wp');
                        
                        cd ..
                        clear c1_new c2_new c3_new c4_new c5_new c6_new c7_new
                        clear Affine image lkp ll mg mn MT Tbias tpm Twarp vr wp eyes_vol holes_vol WMexclude_vol
                    end
                    
                    
                    for condloop=1: length(lesion_conduct)
                        
                        this_conduct=lesion_conduct(condloop);
                        close all
                        % Run ROAST 7 to get the output for the lesioned brain
                        % Using the lesion conductance specified above
                        % This could easily be looped for different lesion sizes and conductances
                        addpath(['~/',ROAST_dir])
                        cd (['~/',ROAST_dir])
                        ROASTtag=strcat('cond',num2str(this_conduct));
                        
                        
                        if not(isfolder(strcat(subj,'/',LESIONtag,'_',ROASTtag)))
                            try
                                system(char(strcat('mkdir',{' '},subj,'/',LESIONtag,'_',ROASTtag)));
                                
                                
                                if  not(isfile(strcat(subj,'/',LESIONtag,'_header.mat'))) && this_conduct~=0.6
                                    system(char(strcat('cp',{' '},subj,'/',LESIONtag,'_cond0.6/',subj,'_',LESIONtag,'_cond0.6.msh',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'.msh')));
                                    system(char(strcat('cp',{' '},subj,'/',LESIONtag,'_cond0.6/',subj,'_',LESIONtag,'_cond0.6.mat',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'.mat')));
                                    system(char(strcat('cp',{' '},subj,'/',LESIONtag,'_cond0.6/',subj,'_',LESIONtag,'_cond0.6_mask_elec.nii',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'_mask_elec.nii')));
                                    system(char(strcat('cp',{' '},subj,'/',LESIONtag,'_cond0.6/',subj,'_',LESIONtag,'_cond0.6_mask_gel.nii',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'_mask_gel.nii')));
                                end
                                
                                %  system(char(strcat('cp',{' '},subj,'/R1_sz4_cond0.6/',subj,'_R1_sz4_cond0.6_mask_gel.nii',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'_mask_gel.nii')));
                                %  system(char(strcat('cp',{' '},subj,'/R1_sz4_cond0.6/',subj,'_R1_sz4_cond0.6_mask_elec.nii',{' '},subj,'/',subj,'_',LESIONtag,'_',ROASTtag,'_mask_elec.nii')));
                                
                                T1LesionName=strcat(subj,'_',LESIONtag,'.nii');
                                lesionT1=strcat(subj,'/',T1LesionName);
                                
                                % Run roast7 with the lesioned data
                                fin=roast7(lesionT1,montage,'simulationtag', ROASTtag,...
                                    'conductivities',struct('lesion',this_conduct),'elecSize', elecsize);
                                disp(fin)
                                
                                cd(subj)
                                system(char(strcat('mv',{' '},subj,'_',LESIONtag,'_',ROASTtag,'*',{' '},LESIONtag,'_',ROASTtag)));
                            catch
                            end
                        end
                        cd ..
                    end
                else
                    disp([LESIONtag,'- lesion was outside the brain, so skipping it'])
                end
            end
        end
    end
end


