%This program generates synthetic PIV images and exports validation data.
%
% Three-dimensional extension: 2022 Flow Imaging Lab at Mudd (Prof. Leah
% Mendelson, Zhian Zhou)
% 
% Original piv-image-generator:
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
baseOutput = '../../out';

% configure images and cameras
sizeX=1024; %Image width without margins
sizeY=1024; %Image height without margins
scale=7.5*10^-2; % mm per pixel

% use machine vision toolbox to create camera array, units of mm throughout
pixPitch = 3.45e-3; % pixel dimension (in mm)
fL = 25; % focal length (in mm)

% create base camera with shared parameters for all cameras
camBase = CentralCamera('focal', fL, 'pixel', pixPitch, ...
    'resolution', [sizeX sizeY], 'centre', [sizeX/2 sizeY/2], 'name', 'camBase');
arrayName = 'fourCamRing'; % identifier for camera array configuration (used in file path)

% vectors of camera positions in m
showCameras=1; % for debugging camera positions, doesn't look great in mm
xpos = [-100 100 -100 100];
ypos = [-100 -100 100 100]; %mvtb appears to use world coordinates y+ down
zpos = [-542 -542 -542 -542];

% camera rotations about each axis in deg
rx = [-10 -10 10 10];
ry = [10 -10 10 -10];
rz = [0 0 0 0];

saveMultCal = 0; % enable to save calibration files for multiple combinations of cameras
% disable to save one calibration file containing all cameras

camCombos = {[1,2,3,4],...
            [1,2,3],...
            [2,3,4]}; % cell array containing each separate combination of cameras to save

% create a cell array of all the cameras (to do: move out of config file)
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
occluded=1; % true = occluded, false = no occlusion
body.file = 'Block.stl'; % stl file of body/object
body.scale = 0.1; % if stl needs resizing
body.Position = [0 -5 10]; % location of body centroid, y+ down right now (image-style coordinates, in mm)
body.Shade = 1; % bright or dark occlusion (1 = bright, 0 = dark)

% display parameters for flow field
displayFlowField=true; %Display image of each flow field,
closeFlowField=false; %and close it automatically

%flows={'rk_uniform' 'rankine_vortex' 'parabolic' 'uniform' 'stagnation',...
%        'shear', 'shear_22d3', 'shear_45d0', 'decaying_vortex'};
flows={'rankine_vortex'};
%flows={'vortex_ring'};

% configure PIV
bitDepths=8; % leave at 8 bits for all tests
deltaXFactor=0.25; % max. displacement as a fraction of the final window size
particleRadius=2.5; % in pixels
Ni=1; % # of particles in each window
noiseLevel=0; % turn off noise for now
outOfPlaneStdDeviation=0; % turn off out of plane motion for now
numberOfRuns=1; % number of trials with each parameter set to generate
numberOfFrames = 4; % number of frames (constant dt) to generate in each image sequence (minimum 2 for PIV, minimum 4 for PTV)
winSize = [64]; % interrogation window sizes (final)
sheetThickness = [24]; % light sheet thickness in mm
zWinScale = 1; % scale of z interrogation window size relative to x and y (assumed to be same)
singlePart = 0; % binary, when on generates images of a single particle centered in the volume for normalizing Q

generate3DPIVImagesAllCombinations;
