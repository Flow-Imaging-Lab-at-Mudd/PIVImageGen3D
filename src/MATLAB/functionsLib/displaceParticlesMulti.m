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

function [particleMapOut] = displaceParticlesMulti(particleMap, flowField, dim, Frames)

%   Returns:
%   Displaced particles for second image in pair, with intensities, in same
%   point order as original particles
    
    particleMapOut = particleMap;

    switch dim
        case 2
           for n=1:length(particleMap.allParticles)
               x = particleMap.allParticles(n).x;
               y = particleMap.allParticles(n).y;

               for nF = 1:Frames-1
                   [x1, y1] = flowField.computeDisplacementAtImagePosition(x(end), y(end));
                   x = [x x1];
                   y = [y y1];
                end

                   particleMapOut.allParticles(n).x = x;
                   particleMapOut.allParticles(n).y = y;
            end

        case 3
             for n=1:length(particleMap.allParticles)
                   x = particleMap.allParticles(n).x;
                   y = particleMap.allParticles(n).y;
                   z = particleMap.allParticles(n).z;

                   for nF = 1:Frames-1
                        [x1, y1, z1] = flowField.computeDisplacementAtImagePosition(x(end), y(end), z(end));
                        x = [x x1];
                        y = [y y1];
                        z = [z z1];
                   end

                   particleMapOut.allParticles(n).x = x;
                   particleMapOut.allParticles(n).y = y;
                   particleMapOut.allParticles(n).z = z;
            end
    end
        
end
