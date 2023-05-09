% writes camera data in format for openfv refocusing

function res = writeCamConfig(cams,arrayName,baseOutput, scaleProps,camCombos)

    basePath = [baseOutput filesep arrayName];
    calPath = [basePath filesep 'calibration_results'];

    if ~isdir(basePath)
        mkdir(basePath);
    end

    if ~isdir(calPath)
        mkdir(calPath);
    end

    for ncal = 1:length(camCombos)
        outFile = [calPath filesep 'calibrationResults' num2str(ncal) '.dat'];
        fid = fopen(outFile,'w');
        fprintf(fid, 'Synthetic Calibration from Image Generator \n');
        fprintf(fid, '0 \n'); % no reprojection error because perfect camera model
        fprintf(fid, [num2str(scaleProps.X) '\t' num2str(scaleProps.Y) '\t' num2str(1/scaleProps.perpix) '\n']);

        useCams = camCombos{ncal};
        fprintf(fid, [num2str(length(useCams)) '\n']);
        fclose(fid);
    
        fid = fopen(outFile,'a');

        

        for ncam = 1:length(useCams)
            currentCam = cams{useCams(ncam)};
            Pmat = currentCam.C;
    
            % invert y to account for coordinate differences
            %Pmat(2,2) = -Pmat(2,2);
            %Pmat(2,4) = -Pmat(2,4); not needed, but probably not working with
            %all rotation possibilities
    
            position = currentCam.T.t'; % write position, units are mm
            fprintf(fid, [currentCam.name '\n']);
            dlmwrite(outFile,Pmat,'-append','Delimiter','\t');
            dlmwrite(outFile,position,'-append','Delimiter','\t');
        end
    
        fprintf(fid,'0'); % add is refractive = 0 (for pinhole) at end
    
        fclose(fid);
    end

    save([calPath filesep 'cameras.mat'],'cams','camCombos'); % create .m file for camera metadata
end