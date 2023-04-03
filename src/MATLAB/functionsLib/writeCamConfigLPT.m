% writes camera data in format for openLPT
% based on CalibMatToTXTV2 from OpenLPT

function res = writeCamConfigLPT(cams,arrayName,baseOutput, scaleProps,camCombos)

    basePath = [baseOutput filesep arrayName];
    calPath = [basePath filesep 'calibration_results'];

    if ~isdir(basePath)
        mkdir(basePath);
    end

    if ~isdir(calPath)
        mkdir(calPath);
    end

    for ncal = 1:length(camCombos)
        outFile = [calPath filesep 'calibrationResultsLPT' num2str(ncal) '.txt'];
        fid = fopen(outFile,'w');
        fprintf(fid, '# Camera configuration file \n');
        fprintf(fid, '# generated %s\n \n', datetime);

        useCams = camCombos{ncal};
       
        fprintf(fid, [num2str(length(useCams)) '    # camera number\n']);
        fclose(fid);

        fid = fopen(outFile,'a');
        for ncam = 1:length(useCams)
            currentCam = cams{useCams(ncam)};

            T = currentCam.T.T;
            Tinv = T^(-1);
            Rinv = Tinv(1:3, 1:3);
            Tinv = Tinv(1:3, 4);

            fprintf(fid, '\n#camera %d\n', useCams(ncam));
            fprintf(fid,'%d    #Noffh\n',0); % assumed zero
            fprintf(fid,'%d    #Noffw\n',0); % assumed zero
            fprintf(fid,'%d    #Npixw\n',currentCam.nu);
            fprintf(fid,'%d    #Npixh\n',currentCam.nv);
            fprintf(fid,'%f    #wpix\n',currentCam.rho(1));
            fprintf(fid,'%f    #hpix\n',currentCam.rho(2));
            fprintf(fid,'%f    #f_eff\n',currentCam.f);
            fprintf(fid,'%f    #kr\n',0); % assumed zero if no distortion?
            fprintf(fid,'%d    #kx\n',1);
            fprintf(fid,'%f    #R\n',currentCam.T.R);
            fprintf(fid,'%f    #T\n',currentCam.T.t);
            fprintf(fid,'%f    #Rinv\n', Rinv);
            fprintf(fid,'%f    #Tinv\n', Tinv);
        end
    
        fclose(fid);
    end

    save([calPath filesep 'camerasLPT.mat'],'cams','camCombos'); % create .m file for camera metadata
end