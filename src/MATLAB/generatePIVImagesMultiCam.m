%This program generates synthetic PIV images and exports validation data.
%Copyright (C) 2019  Luís Mendes, Prof. Rui Ferreira, Prof. Alexandre Bernardino
%
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%
%Special thanks go to Ana Margarida and Rui Aleixo
%and their initial effort on building a draft for a similar tool.

function [ IvolMulti particleMapMulti, flowField ] = generatePIVImagesMultiCam( ...
          flowParameters, imageProperties, pivParameters, run, cam, arrayName, baseOutput, occluded, body)
%generatePIVImages Generates a pair of Synthetic PIV images according to specified
%paramteres and properties.
%   flowParameters flow related configuration
%   imageProperties image related properties and px to mm units conversion factor
%   pivParameters PIV related configuration
%   run current PIV image generation run number
%   displayFlowField true, display an image on screen with the flow field
%   closeFlowField true, close figure with flow field after creating it
%   Returns:
%   Im0 the first image of the PIV pair, with randomly placed particles according to configuration
%   Im1 the displaced image of the PIV pair
%   particleMap detailed information about all particles considered for image generation
%   flowField the instantiated flow field object for computing displacements

tic();

%outFolder = [baseOutput filesep arrayName filesep createPathNameForTestAndConditions( flowParameters, pivParameters )];
outFolder = [baseOutput filesep arrayName filesep 'data'];
metaFolder = [baseOutput filesep arrayName filesep 'eval']; % folder for metadata and evaluation data

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

if ~exist(metaFolder, 'dir')
    mkdir(metaFolder);
end

for ncam = 1:length(cam)
    outCamera = [outFolder filesep cam{ncam}.name];
    if ~exist(outCamera, 'dir')
        mkdir(outCamera);
    end
end


minDI = min(pivParameters.lastWindow(1), pivParameters.lastWindow(1));

%Convert maxVelocity from mm/s to px/s and compute adequate dt for the
%deltaXFactor.
flowParameters.maxVelocityPixel = flowParameters.maxVelocity / imageProperties.mmPerPixel;
flowParameters.dt = (minDI * flowParameters.deltaXFactor) / flowParameters.maxVelocityPixel;
flowField = createFlow(flowParameters, imageProperties);
disp(['Generating flow: ' flowField.getName()])
disp(['to: ' outFolder]);
disp(['dt=' num2str(flowParameters.dt)]);

switch flowParameters.dimField
    case 2
    [flowField, particleMap] = createParticles(flowParameters, pivParameters, imageProperties, flowField);
    
    [x0s, y0s] = meshgrid(0:imageProperties.sizeX-1,0:imageProperties.sizeY-1);
    [x1s, y1s] = flowField.computeDisplacementAtImagePosition(x0s, y0s);
    
    us = x1s - x0s;
    vs = y1s - y0s;
    absUs=abs(us(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2));
    absVs=abs(vs(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2));
    normVs=sqrt(us(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2).^2 + ...
        vs(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2).^2);
    disp(['MaxU is ' num2str(max(max(absUs)))]);
    disp(['MaxV is ' num2str(max(max(absVs)))]);
    disp(['Max velocity is ' num2str(max(max(normVs)))]);

    case 3
    [flowField, particleMap] = createParticles(flowParameters, pivParameters, imageProperties, flowField);
    
    [x0s, y0s, z0s] = meshgrid(0:imageProperties.sizeX-1,0:imageProperties.sizeY-1, 0:imageProperties.voxPerSheet-1);
    [x1s, y1s, z1s] = flowField.computeDisplacementAtImagePosition(x0s, y0s, z0s);
    
    us = x1s - x0s;
    vs = y1s - y0s;
    ws = z1s - z0s;
    absUs=abs(us(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2));
    absVs=abs(vs(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2));
    %absWs=abs(ws(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2));
    normVs=sqrt(us(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2).^2 + ...
        vs(imageProperties.marginsX/2 + 1:end-imageProperties.marginsX/2,imageProperties.marginsY/2 + 1:end-imageProperties.marginsY/2).^2);
    disp(['MaxU is ' num2str(max(max(absUs)))]);
    disp(['MaxV is ' num2str(max(max(absVs)))]);
    disp(['Max velocity is ' num2str(max(max(normVs)))]);
end

if flowParameters.display
    f = figure;
    
    switch flowParameters.dimField
        case 2
            quiver(x0s(1:10:end, 1:10:end), y0s(1:10:end, 1:10:end), us(1:10:end, 1:10:end), vs(1:10:end, 1:10:end));
        case 3
            skip = 25;
            subplot(1,3,1)
            quiver3(x0s(1:skip:end, 1:skip:end, 1:skip:end), y0s(1:skip:end, 1:skip:end, 1:skip:end), z0s(1:skip:end, 1:skip:end, 1:skip:end), us(1:skip:end, 1:skip:end, 1:skip:end), vs(1:skip:end, 1:skip:end, 1:skip:end), ws(1:skip:end, 1:skip:end, 1:skip:end));
            axis equal

            subplot(1,3,2)
            quiver(x0s(1:skip:end, 1:skip:end,round(imageProperties.voxPerSheet/2)), y0s(1:skip:end, 1:skip:end, round(imageProperties.voxPerSheet/2)), ...
                us(1:skip:end, 1:skip:end,round(imageProperties.voxPerSheet/2)), vs(1:skip:end, 1:skip:end,round(imageProperties.voxPerSheet/2)));
            axis equal

            subplot(1,3,3)
            quiver(z0s(1:skip:end, imageProperties.sizeX/2, 1:skip:end), y0s(1:skip:end, imageProperties.sizeX/2, 1:skip:end), ...
                ws(1:skip:end, imageProperties.sizeX/2,1:skip:end), vs(1:skip:end, imageProperties.sizeX/2, 1:skip:end));
            axis equal

    end
    
    title([flowField.getName() ' - ' 'Noise' num2str(pivParameters.noiseLevel, '%02d') ]);
    %saveas(gcf, [ outFolder filesep flowParameters.flowType '_flowField.jpg' ]);
    if flowParameters.close
        close(f);
    end
end

% move export earlier - probably don't need everything exported but leaving
% for now

if ~pivParameters.singlePart
    exportFlowFields(flowParameters, pivParameters, imageProperties, particleMap, flowField, metaFolder, run);
end

particleMapMulti = displaceParticlesMulti(particleMap, flowField, flowParameters.dimField, imageProperties.nFrames);

% rescale particle positions to mm before projecting into each camera
% (going through steps in pixels first generates reasonable displacements)
particleWorldMulti = rescaleParticles(particleMapMulti,imageProperties, flowParameters.dimField);


% loop over all multi cameras and save images
for ncam = 1:length(cam)
    %[Im0] = createCameraImage(pivParameters, imageProperties, particleWorld, cam{ncam});
    %[Im1] = createCameraImage(pivParameters, imageProperties, particleWorld2, cam{ncam});
    [Imstack] = createCameraImage(pivParameters, imageProperties, particleWorldMulti, cam{ncam});
    [Imstack] = adjustImagesIntensity(pivParameters, Imstack);

    if occluded
        bodyImg = projectBodyPoints(body,cam{ncam});
        
        % make copies of particle field without occlusion
        Imref = Imstack;
        [Imstack,msk] = overlayBody(body,bodyImg,Imstack);
    
    end
    
    %Save PIV image and particle positions

    for frame = 1:imageProperties.nFrames
        imwrite(Imstack(:,:,frame), [outFolder filesep cam{ncam}.name filesep...
            num2str(run, '%02d') '_' num2str(frame,'%02d') '.tif']);
          
        if occluded
            imwrite(Imref(:,:,frame), [outFolder filesep cam{ncam}.name filesep...
                num2str(run, '%02d') '_' num2str(frame,'%02d') '_part.tif']);
            imwrite(msk, [outFolder filesep cam{ncam}.name filesep num2str(run, '%02d') '_msk.tif']);
        end
    end
    toc();
    disp('--------------------------------------------------------')
end

[IvolMulti] = renderParticles3D(pivParameters, imageProperties, particleMapMulti, flowParameters.dimField);

[IvolMulti] = adjustImagesIntensity(pivParameters,IvolMulti); % same adjustment function works

save([metaFolder filesep 'particles' num2str(run, '%02d') '.mat'],'particleMapMulti','particleWorldMulti','IvolMulti');
save([metaFolder filesep 'settings.mat'],'pivParameters','flowParameters','imageProperties');

end

