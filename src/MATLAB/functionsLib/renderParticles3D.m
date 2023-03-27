%This program generates synthetic PIV images and exports validation data.
%Modified for 3D volume generation by Leah Mendelson, Zhian Zhou
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


function [ IvolMulti ] = renderParticles3D(pivParameters, imageProperties, particleMap, dim)
%renderParticle Renders a particle at given position (y,x,z) with ...
% specified central intensity.
%   pivParameters Specific PIV parameters
%   imageProperties Image properties
%   centerX central x particle position
%   centerY central y particle position
%   intensity central particle max. intensisty
%   Im image to superimpose particle
%   Returns:
%   Im the modified matrix with the newly rendered particle.

   d = pivParameters.particleRadius*2.0;
   
   renderRadius = pivParameters.renderRadius;

    xAll = reshape([particleMap.allParticles.x],imageProperties.nFrames,[])';
    yAll = reshape([particleMap.allParticles.y],imageProperties.nFrames,[])';

    switch dim
        case 2
            zAll = [particleMap.allParticles.z]';
            zAll = repmat(zAll, 1, imageProperties.nFrames);
        case 3
            zAll = reshape([particleMap.allParticles.z],[],imageProperties.nFrames);
    end

    intensities = reshape([particleMap.allParticles.intensities],imageProperties.nFrames,[])';

   for frame = 1:imageProperties.nFrames
   
       xcenter = xAll(:,frame);
       ycenter = yAll(:,frame);
       zcenter = zAll(:,frame);
       intensity = intensities(:,frame);
    
       maxX = min(round(xcenter + renderRadius), imageProperties.sizeX);
       minX = max(round(xcenter - renderRadius), 1);
       maxY = min(round(ycenter + renderRadius), imageProperties.sizeY);
       minY = max(round(ycenter - renderRadius), 1);
       maxZ = min(round(zcenter + renderRadius), imageProperties.voxPerSheet);
       minZ = max(round(zcenter - renderRadius), 1);
    
       Ivol = zeros([imageProperties.sizeY imageProperties.sizeX imageProperties.voxPerSheet]);
       
       for i = 1:length(maxX)
           xrange = minX(i):maxX(i);
           yrange = minY(i):maxY(i);
           zrange = minZ(i):maxZ(i);
    
           if maxY(i)-minY(i) > 0 && maxX(i)-minX(i) > 0 && maxZ(i)-minZ(i) > 0   
    
               [xs, ys, zs] = meshgrid(xrange, yrange, zrange);
      
               Ivol(yrange,xrange,zrange) = Ivol(yrange,xrange,zrange) + ...
                   intensity(i) * exp(-((double(xs)+0.5-xcenter(i)).^2 + (double(ys)+0.5-ycenter(i)).^2 + (double(zs)+0.5-zcenter(i)).^2)./(0.125*d.^2));
               test3d = intensity(i) * exp(-((double(xs)+0.5-xcenter(i)).^2 + (double(ys)+0.5-ycenter(i)).^2 + (double(zs)+0.5-zcenter(i)).^2)./(0.125*d.^2));
               test2d = intensity(i) * exp(-((double(xs)+0.5-xcenter(i)).^2 + (double(ys)+0.5-ycenter(i)).^2)./(0.125*d.^2));
               bright3d(i) = max(test3d(:));
               bright2d(i) = max(test2d(:));
           end
    
       end
    
        leftMargin = ceil(imageProperties.marginsX/2);
        rightMargin = ceil(imageProperties.sizeX - imageProperties.marginsX/2);
        topMargin = ceil(imageProperties.marginsY/2);
        bottomMargin = ceil(imageProperties.sizeY - imageProperties.marginsY/2);
        frontMargin = ceil(imageProperties.marginsZ/2);
        backMargin = ceil(imageProperties.voxPerSheet - imageProperties.marginsZ/2);
    
        Ivol = Ivol(topMargin+1:bottomMargin, leftMargin+1:rightMargin,frontMargin+1:backMargin);
   end

   IvolMulti(:,:,:,frame) = Ivol;
end

