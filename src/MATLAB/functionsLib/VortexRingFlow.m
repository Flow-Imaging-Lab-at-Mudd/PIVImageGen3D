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

classdef VortexRingFlow
%VORTEXRINGFLOW Class that defines a 3D vortex ring flow field

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        voxSizeZ
        marginsX
        marginsY
        marginsZ
        xc
        yc
        zc
        circulation
        dt
        Weight = 1.0;
        coreRadius = 50.0;
        majRadius = 150.0;
    end
    methods
        function obj = VortexRingFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.voxSizeZ = double(imageProperties.voxPerSheet);
            obj.marginsX = double(imageProperties.marginsX);
            obj.marginsY = double(imageProperties.marginsY);
            obj.marginsZ = double(imageProperties.marginsZ);
            %Arrays are indexed at one, but coordinates start at 0, so ys[obj.imSizeY]=obj.imSizeY-1
            obj.yc = (obj.imSizeY-1)/2.0; 
            obj.xc = (obj.imSizeX-1)/2.0;
            obj.zc = (obj.voxSizeZ-1)/2.0;
            obj.circulation = obj.maxVelocityPixel / obj.coreRadius;
        end
        
        function [ x1, y1, z1 ] = computeDisplacementAtImagePosition(obj, x0, y0, z0)           
            R=sqrt((x0 - obj.xc).^2 + (z0 - obj.zc).^2);
            %r = abs(R - obj.majRadius);
            rplane = R - obj.majRadius;
            r = sqrt(rplane.^2 + (y0-obj.yc).^2);
            phi0 = atan2((z0 - obj.zc),(x0 - obj.xc));
            theta0=atan2((y0 - obj.yc),rplane);
            
            x1 = zeros(size(x0,1), size(x0,2), size(x0,3));
            y1 = zeros(size(x0,1), size(x0,2), size(x0,3));
            z1 = zeros(size(x0,1), size(x0,2), size(x0,3));
            r1 = zeros(size(x0,1), size(x0,2), size(x0,3));
            
            %Inside the forced Vortex Radius
            intInd = r <= obj.coreRadius; % inside indices

            if ~isempty(r(intInd))
               theta1 = obj.Weight .* obj.circulation .* obj.dt + theta0(intInd);
               r1(intInd) = r(intInd) .* cos(theta1);
               y1(intInd) = r(intInd) .* sin(theta1);
            end

%             if ~isempty(r(r <= obj.coreRadius))
%                theta1 = obj.Weight .* obj.circulation .* obj.dt + theta0(abs(r) <= obj.coreRadius);
%                r1(abs(r) <= obj.coreRadius) = r(abs(r) <= obj.coreRadius) .* cos(theta1);
%                y1(abs(r) <= obj.coreRadius) = r(abs(r) <= obj.coreRadius) .* sin(theta1);
%             end
            
            %Outside the forced Vortex Radius (free vortex)            
            if ~isempty(r(r > obj.coreRadius))
               theta1 = obj.Weight .* obj.circulation .* obj.dt .* obj.coreRadius^2 ./ r(abs(r) > obj.coreRadius).^2 + theta0(abs(r) > obj.coreRadius);
               r1(abs(r) > obj.coreRadius) = r(abs(r) > obj.coreRadius) .* cos(theta1);
               y1(abs(r) > obj.coreRadius) = r(abs(r) > obj.coreRadius) .* sin(theta1);
            end

            %Handle axisymmetry (no velocity in phi direction)
            x1 = (r1+obj.majRadius).*cos(phi0);
            z1 = (r1+obj.majRadius).*sin(phi0);
            
            x1 = x1 + obj.xc;
            y1 = y1 + obj.yc;
            z1 = z1 + obj.zc;
        end
        
        function [name] = getName(~) 
            name = 'Vortex Ring flow';
        end
        
        %function obj = set.Weight(obj, weight)
        %    obj.Weight = weight;
        %end
    end
end
	
