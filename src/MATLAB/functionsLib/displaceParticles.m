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

function [particleMapOut] = displaceParticles(particleMap, flowField)

%   Returns:
%   Displaced particles for second image in pair, with intensities, in same
%   point order as original particles
    
    particleMapOut = particleMap;

    for n=1:length(particleMap.allParticles)
       x = particleMap.allParticles(n).x;
       y = particleMap.allParticles(n).y;
       intensityA = particleMap.allParticles(n).intensityA;
       [x1, y1] = flowField.computeDisplacementAtImagePosition(x, y);
       displacedX = x1;
       displacedY = y1;
       particleMapOut.allParticles(n).x = x1;
       particleMapOut.allParticles(n).y = y1;
    end
        
end
