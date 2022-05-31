% writes camera data in format for openfv refocusing

function res = writeCamConfig(cams,arrayName,baseOutput, scaleProps)

    basePath = [baseOutput filesep arrayName];

    if ~isdir(basePath)
        mkdir(basePath);
    end

    outFile = [basePath filesep 'calibrationResults1.dat'];
    fid = fopen(outFile,'w');
    fprintf(fid, 'Synthetic Calibration from Image Generator \n');
    fprintf(fid, '0 \n'); % no reprojection error because perfect camera model
    fprintf(fid, [num2str(scaleProps.X) '\t' num2str(scaleProps.Y) '\t' num2str(1/scaleProps.perpix) '\n']);
    fprintf(fid, [num2str(length(cams)) '\n']);
    fclose(fid);

    fid = fopen(outFile,'a');
    for ncam = 1:length(cams)
        currentCam = cams{ncam};
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