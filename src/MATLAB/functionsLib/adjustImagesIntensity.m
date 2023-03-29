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

function [Imstack] = adjustImagesIntensity(pivParameters, Imstack)
%adjustImagesIntensity Adjust images intensity by either clipping
%   or normalizing, based on allowed maximum pixel bit depth.

maxValue = 2^pivParameters.bits-1;
switch pivParameters.intensityMethod   
    case 'normalize'
        maxI = max(Imstack(:));        
        if maxI > maxValue 
           Imstack = Imstack * maxValue/maxI;
        end

        Imstack = round(Imstack);
    case 'clip'
        Imstack = round(Imstack);

        Imstack(Imstack>maxValue) = maxValue;
             
    otherwise
        error('Unknown intensity method');
end

if pivParameters.bits == 8
    Imstack = uint8(Imstack);

else
    Imstack(Imstack > maxValue) = maxValue;
    Imstack = uint16(Imstack);
end
end

