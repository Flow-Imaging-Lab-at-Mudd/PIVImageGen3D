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

function [particleWorld] = rescaleParticles(particleMap, imageProperties, dim)
    
%   Returns:
%   Particle positions rescaled to mm instead of voxel units and with
%   center of volume at 0,0 in x and y

% calculate shifts in pixels
    shiftx = imageProperties.sizeX/2;
    shifty = imageProperties.sizeY/2;
    shiftz = ceil(imageProperties.marginsZ/2);

    xAll = reshape([particleMap.allParticles.x],imageProperties.nFrames,[])';
    yAll = reshape([particleMap.allParticles.y],imageProperties.nFrames,[])';

    switch dim
        case 2
            zAll = [particleMap.allParticles.z]';
            zAll = repmat(zAll, 1, imageProperties.nFrames);
        case 3
            zAll = reshape([particleMap.allParticles.z],[],imageProperties.nFrames);
    end

    particleWorld.x = (xAll-shiftx)*(imageProperties.mmPerPixel);
    particleWorld.y = (yAll-shifty)*(imageProperties.mmPerPixel);
    particleWorld.z = (zAll-shiftz)*(imageProperties.mmPerPixel);
    %particleWorld.intensityA = [particleMap.allParticles.intensityA
    %particleWorld.intensityB = [particleMap.allParticles.intensityB]';
    particleWorld.intensities = reshape([particleMap.allParticles.intensities],imageProperties.nFrames,[])';
end
