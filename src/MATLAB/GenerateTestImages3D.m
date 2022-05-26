%This program generates synthetic PIV images and exports validation data.
%
% Three-dimensional extension: 2022 Flow Imaging Lab at Mudd (Prof. Leah
% Mendelson, Zhian Zhou)
% 
% Original piv-imageEr:
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
addpath functionsLib;

% specify base path of where to save data
baseOutput = 'out';

% configure images and cameras
sizeX=512; %Image width without margins
sizeY=512; %Image height without margins
scale=7.5*10^-2; % mm per pixel

% use machine vision toolbox to create camera array
pixPitch = 3.45e-6; % pixel dimension (in m)
fL = 0.025; % focal length (in m)

% create base camera with shared parameters for all cameras
camBase = CentralCamera('focal', fL, 'pixel', pixPitch, ...
    'resolution', [sizeX sizeY], 'centre', [sizeX/2 sizeY/2], 'name', 'camBase');
arrayName = 'twoCam'; % identifier for camera array configuration (used in file path)

% vectors of camera positions in m
showCameras=true; % for debugging camera positions
%xpos = [-0.1 0.1];
xpos = [0 0];
ypos = [0 0]; %mvtb appears to use world coordinates y+ down
zpos = [-0.542 -0.542];

% rotations about each axis in deg
rx = [0 0];
%ry = [10 -10];
ry = [0 0];
rz = [0 0];

% create a cell array of all the cameras
for ncam = 1:length(xpos)
    % rotation matrices
    rxm = rotx(rx(ncam));
    rym = roty(ry(ncam));
    rzm = rotz(rz(ncam));
    rot = rxm*rym*rzm;
    T = SE3(rot,[xpos(ncam) ypos(ncam) zpos(ncam)]);
    camTmp = camBase.move(T);
    camTmp.name = ['cam' num2str(ncam)];
    cams{ncam} = camTmp;
    
    if showCameras
        figure(1)
        camTmp.plot_camera
        hold on
        axis equal
    end
end

% configure bodies/surfaces/occlusions
occluded=true;
bodyfile = 'Block.stl'; % stl file of body/object
bodyscale = 0.1; % if stl needs resizing
bodyPosition = [0 0 10]; % location of body centroid

% display parameters for flow field
displayFlowField=false; %Display image of each flow field,
closeFlowField=false; %and close it automatically

%flows={'rk_uniform' 'rankine_vortex' 'parabolic' 'uniform' 'stagnation',...
%        'shear', 'shear_22d3', 'shear_45d0', 'decaying_vortex'};
flows={'rankine_vortex'};

% configure PIV
bitDepths=8; % leave at 8 bits for all tests
deltaXFactor=0.25; % max. displacement as a fraction of the final window size
particleRadius=1.5; % in pixels
Ni=1; % # of particles in each window
noiseLevel=0; % turn off noise for now
outOfPlaneStdDeviation=0; % turn off out of plane motion for now
numberOfRuns=1; % number of trials with each parameter set to generate
winSize = [32]; % interrogation window sizes
sheetThickness = [30]; % light sheet thickness in mm
zWinScale = 1; % scale of z interrogation window size relative to x and y (assumed to be same)

generate3DPIVImagesAllCombinations;
