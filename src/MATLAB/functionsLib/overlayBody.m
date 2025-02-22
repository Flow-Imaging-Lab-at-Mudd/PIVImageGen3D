function [Imsk,msk] = overlayBody(body,bodyImg,Im0)

%OVERLAYBODY Overlays mask on synthetic image

    % preallocate mask
    msk = logical(zeros(size(Im0,1),size(Im0,2)));
    
    for nmesh = 1:length(body.ConnectivityList)
        indices = body.ConnectivityList(nmesh,:)';
        region = bodyImg(indices,:);
        xregion = [region(:,1); region(1,1)];
        yregion = [region(:,2); region(1,2)];
        imageVertices = [xregion yregion];
        currTriangle = drawpolygon('Position',imageVertices);
        mskTmp = createMask(currTriangle,Im0);
        msk = or(msk,mskTmp);
        %Im0 = regionfill(Im0,xregion,yregion);
    end
    
    for frame = 1:size(Im0,3)

        % assumes 8 bit for now
        tmp = Im0(:,:,frame);
        tmp(msk) = 255*body.Shade;
        Imsk(:,:,frame) = tmp;
    %    Im1(msk) = 255*body.Shade; % same occlusion for both frames for now

    end

end

