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

function [ Im0, Im1, particleMap, flowField ] = generatePIVImagesMultiCam( ...
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

if flowParameters.display
    f = figure;
    quiver(x0s(1:10:end, 1:10:end), y0s(1:10:end, 1:10:end), us(1:10:end, 1:10:end), vs(1:10:end, 1:10:end));
    title([flowField.getName() ' - ' 'Noise' num2str(pivParameters.noiseLevel, '%02d') ]);
    saveas(gcf, [ outFolder filesep flowParameters.flowType '_flowField.jpg' ]);
    if flowParameters.close
        close(f);
    end
end

% move export earlier - probably don't need everything exported but leaving
% for now
exportFlowFields(flowParameters, pivParameters, imageProperties, particleMap, flowField, metaFolder, run);

particleMap2 = displaceParticles(particleMap, flowField);

% rescale particle positions to mm before projecting into each camera
% (going through steps in pixels first generates reasonable displacements)
particleWorld = rescaleParticles(particleMap,imageProperties);
particleWorld2 = rescaleParticles(particleMap2,imageProperties);


% loop over all multi cameras and save images
for ncam = 1:length(cam)
    [Im0] = createCameraImage(pivParameters, imageProperties, particleWorld, cam{ncam});
    [Im1] = createCameraImage(pivParameters, imageProperties, particleWorld2, cam{ncam});
    [Im0, Im1] = adjustImagesIntensity(pivParameters, Im0, Im1);

    if occluded
        bodyImg = projectBodyPoints(body,cam{ncam});
        
        % make copies of particle field without occlusion
        Im0ref = Im0;
        Im1ref = Im1; 
        [Im0,Im1,msk] = overlayBody(body,bodyImg,Im0,Im1);
    
    end
    
    %Save PIV image and particle positions
    imwrite(Im0, [outFolder filesep cam{ncam}.name filesep num2str(run, '%02d') '_0.tif']);
    imwrite(Im1, [outFolder filesep cam{ncam}.name filesep  num2str(run, '%02d') '_1.tif']);
    
    if occluded
        imwrite(Im0ref, [outFolder filesep cam{ncam}.name filesep num2str(run, '%02d') '_0_part.tif']);
        imwrite(Im1ref, [outFolder filesep cam{ncam}.name filesep num2str(run, '%02d') '_1_part.tif']);
        imwrite(msk, [outFolder filesep cam{ncam}.name filesep num2str(run, '%02d') '_msk.tif']);
    end
    
    toc();
    disp('--------------------------------------------------------')
end

[Ivol1] = renderParticles3D(pivParameters, imageProperties, particleMap);
[Ivol2] = renderParticles3D(pivParameters, imageProperties, particleMap2);
[Ivol1,Ivol2] = adjustImagesIntensity(pivParameters,Ivol1,Ivol2); % same adjustment function works

save([metaFolder filesep 'particles' num2str(run, '%02d') '.mat'],'particleMap','particleWorld','particleMap2','particleWorld2','Ivol1','Ivol2');
save([metaFolder filesep 'settings.mat'],'pivParameters','flowParameters','imageProperties');

end

