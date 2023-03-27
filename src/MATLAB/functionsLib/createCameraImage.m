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

function [Images] = createCameraImage(pivParameters, imageProperties, particleMap, cam)
%createImages Creates a particle image given the particles position map, as well as, image, camera and PIV parameters.
%   Returns:
%   Im0 - the initial image with particles at their initial random placement

    Images = zeros([imageProperties.sizeY, imageProperties.sizeX, imageProperties.nFrames]);

    for frame = 1:imageProperties.nFrames

        Im0 = zeros([imageProperties.sizeY, imageProperties.sizeX]);

        for n=1:length(particleMap.x)
           x = particleMap.x(n,frame);
           y = particleMap.y(n,frame);
           z = particleMap.z(n,frame);
           intensityA = particleMap.intensities(n,frame);
           pt = [x y z]'; %trying mm as base unit
           ximg = cam.project(pt);
           xpix(n) = ximg(1);
           ypix(n) = ximg(2);
           Im0 = renderParticle(pivParameters, imageProperties, ximg(1), ximg(2), intensityA, Im0);
        end
        
        leftMargin = ceil(imageProperties.marginsX/2);
        rightMargin = ceil(imageProperties.sizeX - imageProperties.marginsX/2);
        topMargin = ceil(imageProperties.marginsY/2);
        bottomMargin = ceil(imageProperties.sizeY - imageProperties.marginsY/2);
        
        Im0 = Im0(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
    
        if pivParameters.noiseLevel > 0
            %generate white noise
            maxValue = 2^pivParameters.bits-1;
            noiseIm0=wgn(imageProperties.sizeY - imageProperties.marginsY, ...
                imageProperties.sizeX - imageProperties.marginsX, pivParameters.noiseLevel);
            
            noiseIm0 = noiseIm0 .* maxValue / 255.0;
            
            Im0 = Im0 + noiseIm0;
        end

        Images(:,:,frame)=Im0;
    end
end
