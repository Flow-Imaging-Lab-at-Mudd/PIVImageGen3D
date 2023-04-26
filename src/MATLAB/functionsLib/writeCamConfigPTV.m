% writes camera data in format for openfv refocusing

function res = writeCamConfigPTV(cams,arrayName, baseOutput, scaleProps)

    basePath = [baseOutput filesep arrayName];
    calPath = [basePath filesep 'calibration_results'];

    if ~isdir(basePath)
        mkdir(basePath);
    end

    if ~isdir(calPath)
        mkdir(calPath);
    end

    if ~isdir([calPath filesep 'PTV'])
        mkdir([calPath filesep 'PTV']);
    end

    for ncal = 1:length(cams)
        outFile = [calPath filesep 'PTV' filesep cams{ncal}.name];
        fid = fopen(outFile,'w');
        fprintf(fid, [cams{ncal}.name '\n']);
        fclose(fid);

        currentCam = cams{ncal};
        position = currentCam.T.t'; % write position, units are mm
        dlmwrite(outFile,position,'-append','Delimiter',' ');

        rotation = [scaleProps.angles(:,ncal)'];
        rVec = deg2rad(rotation);
        dlmwrite(outFile,rVec,'-append','Delimiter',' ');

        fid = fopen(outFile,'a');
        f = currentCam.f/currentCam.rho(1); % principle distance divided by pixel size; check use of focal length here
        fprintf(fid, [num2str(f) '\n']);
        
        % correction to imaging center
        xh = 0; % no shift for synthetic camera?
        yh = 0; % no shift for synthetic camera?
        fprintf(fid, [num2str(xh) ' ' num2str(yh) '\n']);
        fclose(fid);

        % distortion coefficient (zero if no distortion in model)
        if isempty(currentCam.distortion)
            D = zeros(3,5);
            dlmwrite(outFile,D,'-append','Delimiter',' ');
        else
            %fill in with distortion if using in 
        end

    end

end