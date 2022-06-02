% writes occlusion metadata as .mat file

function res = writeOcclusion(baseOutput, body, arrayName)

    basePath = [baseOutput filesep arrayName];

    if ~isdir(basePath)
        mkdir(basePath);
    end

    outFile = [basePath filesep 'occlusion.mat'];
    save(outFile,'body');
end