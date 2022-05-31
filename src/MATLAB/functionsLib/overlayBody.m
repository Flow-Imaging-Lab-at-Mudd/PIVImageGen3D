function [Im0,Im1] = overlayBody(body,bodyImg,Im0,Im1)

%OVERLAYBODY Overlays mask on synthetic image

    % preallocate mask
    msk = logical(zeros(size(Im0)));
    
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
    
    % assumes 8 bit for now
    Im0(msk) = 255*body.Shade;
    Im1(msk) = 255*body.Shade; % same occlusion for both frames for now

end

