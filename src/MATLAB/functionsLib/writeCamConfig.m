% writes camera data in format for openfv refocusing

function res = writeCamConfig(cams,arrayName,baseOutput)

    basePath = [baseOutput filesep arrayName];

    if ~isdir(basePath)
        mkdir(basePath)
    end

    outFile = [basePath filesep 'calibrationResults4.dat'];
    fid = fopen(outFile,'a');

    for ncam = 1:length(cams)
        currentCam = cams{ncam};
        Pmat = currentCam.C;
        fprintf(fid, [currentCam.name '\n'])
        dlmwrite(outFile,Pmat,'-append','Delimiter','\t')
    end
    fclose(fid)
end