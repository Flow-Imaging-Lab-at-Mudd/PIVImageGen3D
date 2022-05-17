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

clear *; clear GLOBAL *;
close all;

% configure images and cameras
sizeX=512; %Image width without margins
sizeY=512; %Image height without margins

% use machine vision toolbox to create camera
cameras = CentralCamera('focal', 0.015, 'pixel', 10e-6, ...
    'resolution', [sizeX sizeY], 'centre', [sizeX/2 sizeY/2], 'name', 'mycamera');

displayFlowField=true; %Display image of each flow field,
closeFlowField=true; %and close it automatically

%flows={'rk_uniform' 'rankine_vortex' 'parabolic' 'uniform' 'stagnation',...
%        'shear', 'shear_22d3', 'shear_45d0', 'decaying_vortex'};
flows={'rankine_vortex'};

% configure PIV
bitDepths=8; % leave at 8 bits for all tests
deltaXFactor=0.05; % max. displacement as a fraction of the final window size
particleRadius=1.5; % in pixels
Ni=1; % # of particles in each window
noiseLevel=0; % turn off noise for now
outOfPlaneStdDeviation=0; % turn off out of plane motion for now
numberOfRuns=1;
winSize = [32]; % interrogation window sizes
sheetThickness = [30]; % light sheet thickness in mm
zWinScale = 1; % scale of z interrogation window size relative to x and y (assumed to be same)

generate3DPIVImagesAllCombinations;
