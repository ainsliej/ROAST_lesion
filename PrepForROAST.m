function [mriFIX]=PrepForROAST(mri,padNum)
 
    
    nii = load_untouch_nii(mri);
    [FILEPATH, baseFilename,ext] = fileparts(mri);

   if padNum>1
    disp(['Padding ' mri ' by ' num2str(padNum) ' empty slices in all the six directions...']);

    newSize = size(nii.img) + 2*[padNum padNum padNum];
   % mriPD = [baseFilename '_padded' num2str(padNum) ext];

    img = zeros(newSize);
 %   img(padNum+1:end-padNum,padNum+1:end-padNum,padNum+1:end-padNum) = flip(nii.img,3);
	img(padNum+1:end-padNum,padNum+1:end-padNum,padNum+1:end-padNum) = nii.img;
    nii.img = img;
    nii.hdr.dime.dim(2:4) = newSize;
    
    origin = inv([nii.hdr.hist.srow_x;nii.hdr.hist.srow_y;nii.hdr.hist.srow_z;0 0 0 1])*[0;0;0;1];
    origin = origin(1:3) + padNum;
    
    nii.hdr.hist.srow_x(4) = -origin(1)*nii.hdr.hist.srow_x(1)-origin(2)*nii.hdr.hist.srow_x(2)-origin(3)*nii.hdr.hist.srow_x(3);
    nii.hdr.hist.srow_y(4) = -origin(1)*nii.hdr.hist.srow_y(1)-origin(2)*nii.hdr.hist.srow_y(2)-origin(3)*nii.hdr.hist.srow_y(3);
    nii.hdr.hist.srow_z(4) = -origin(1)*nii.hdr.hist.srow_z(1)-origin(2)*nii.hdr.hist.srow_z(2)-origin(3)*nii.hdr.hist.srow_z(3);
%    nii.hdr.hist.srow_z = -nii.hdr.hist.srow_z;

    nii.hdr.hist.qoffset_x = nii.hdr.hist.srow_x(4);
    nii.hdr.hist.qoffset_y = nii.hdr.hist.srow_y(4);
    nii.hdr.hist.qoffset_z = nii.hdr.hist.srow_z(4);
    
   
   end 
   
 M1 = [nii.hdr.hist.srow_x; nii.hdr.hist.srow_y; nii.hdr.hist.srow_z; 0 0 0 1];

M_orient = M1(1:3,1:3);

[~,oriInd] = max(abs(M_orient));
[~,permOrder] = sort(oriInd); % permutation order to RAS system
flipTag = [sign(M_orient(oriInd(1),1)) sign(M_orient(oriInd(2),2)) sign(M_orient(oriInd(3),3))];
% detect if the head is flipped in each direction compared to RAS system

if any(permOrder~=[1 2 3]) || any(flipTag<0)
    


    
  %  if ~exist(mriRAS,'file')
        
        warning(['Input MRI ' mri ' is not in RAS orientation. Re-orienting it into RAS now...']);
        
        img = nii.img;
        
        siz = nii.hdr.dime.dim(2:4);
        
        resolution = nii.hdr.dime.pixdim(2:4);
        
        origin = round(inv(M1)*[0;0;0;1]+1);
        origin = origin(1:3); % voxel coordinates of the origin
        
        for i=1:3
            if flipTag(i)<0
                img = flipdim(img,i); % flipping the volume
                origin(i) = siz(i) - origin(i) + 1; % flipping the origin voxel coordinates
                M_orient(oriInd(i),i) = abs(M_orient(oriInd(i),i)); % update header
            end
        end
        
        img = permute(img,permOrder); % permute the volume
        nii.img = img;
        
        origin = origin(permOrder); % permute the origin coordinates
        
        nii.hdr.dime.dim(2:4) = siz(permOrder); % update header
        
        nii.hdr.dime.pixdim(1) = abs(nii.hdr.dime.pixdim(1)); % update header
        nii.hdr.dime.pixdim(2:4) = resolution(permOrder); % update header
        
        M_orient = M_orient(:,permOrder);
        nii.hdr.hist.srow_x(1:3) = M_orient(1,:);
        nii.hdr.hist.srow_y(1:3) = M_orient(2,:);
        nii.hdr.hist.srow_z(1:3) = M_orient(3,:); % update header
        
        nii.hdr.hist.srow_x(4) = -origin(1)*nii.hdr.hist.srow_x(1)-origin(2)*nii.hdr.hist.srow_x(2)-origin(3)*nii.hdr.hist.srow_x(3);
        nii.hdr.hist.srow_y(4) = -origin(1)*nii.hdr.hist.srow_y(1)-origin(2)*nii.hdr.hist.srow_y(2)-origin(3)*nii.hdr.hist.srow_y(3);
        nii.hdr.hist.srow_z(4) = -origin(1)*nii.hdr.hist.srow_z(1)-origin(2)*nii.hdr.hist.srow_z(2)-origin(3)*nii.hdr.hist.srow_z(3);
        nii.hdr.hist.qoffset_x = nii.hdr.hist.srow_x(4);
        nii.hdr.hist.qoffset_y = nii.hdr.hist.srow_y(4);
        nii.hdr.hist.qoffset_z = nii.hdr.hist.srow_z(4); % update header
      
   % else
      
   % end
    
else


end  

        disp('Your file is now preped, ready for ROAST');
       mriFIX = [FILEPATH filesep baseFilename '_preped' ext];
      
      save_untouch_nii(nii,mriFIX);
end 