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

        currentCam = cams{ncal};
        position = currentCam.T.t'; % write position, units are mm
        dlmwrite(outFile,position,'-append','Delimiter',' ');

        rotation = currentCam.T;
        
        fclose(fid);
    
% %         fid = fopen(outFile,'a');
% % 
% % 
% %         for ncam = 1:length(useCams)
% %             currentCam = cams{useCams(ncam)};
% %             Pmat = currentCam.C;
% %     
% %             % invert y to account for coordinate differences
% %             %Pmat(2,2) = -Pmat(2,2);
% %             %Pmat(2,4) = -Pmat(2,4); not needed, but probably not working with
% %             %all rotation possibilities
% %     
% %             position = currentCam.T.t'; % write position, units are mm
% %             fprintf(fid, [currentCam.name '\n']);
% %             dlmwrite(outFile,Pmat,'-append','Delimiter','\t');
% %             dlmwrite(outFile,position,'-append','Delimiter','\t');
%         end
%     
%         fprintf(fid,'0'); % add is refractive = 0 (for pinhole) at end
%     
%         fclose(fid);
    end

    %save([calPath filesep 'cameras.mat'],'cams','camCombos'); % create .m file for camera metadata
end