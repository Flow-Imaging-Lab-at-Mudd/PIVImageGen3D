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
addpath '../../stl';

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
arrayName = 'renderTest'; % identifier for camera array configuration (used in file path)

% vectors of camera positions in m
showCameras=1; % for debugging camera positions, doesn't look great in mm

% TO DO: WRITE INTO GENERATE CAMERA PATTERN FUNCTION
% theta = linspace(0,2*pi,7);
% theta = theta(1:6);
% xorder = cos(theta);
% yorder = sin(theta);
% xorder = [-2 -1 -1 1 1 2];
% yorder = [0 -1 1 -1 1 0];
% 
% xpos = horzcat(50*xorder,100*xorder,150*xorder,200*xorder,250*xorder,300*xorder);
% ypos = horzcat(50*yorder,100*yorder,150*yorder,200*yorder,250*yorder,300*yorder); %mvtb appears to use world coordinates y+ down
% zpos = -542*ones(size(xpos));
xpos = [0];
ypos = [0];
zpos = [-542];

% camera rotations about each axis in deg
rz = zeros(size(ypos));
% rx = [0];
% ry = [0];
% rz = [0];

saveMultCal = 0; % enable to save calibration files for multiple combinations of cameras
% disable to save one calibration file containing all cameras

% TO DO: INCORPORATE INTO CAMERA PATTERN FUNCTION
camCombos = {[1,2,3,4,5,6],...
            [7,8,9,10,11,12],...
            [13,14,15,16,17,18],...
            [19,20,21,22,23,24],...
            [25,26,27,28,29,30],...
            [31,32,33,34,35,36]}; % cell array containing each separate combination of cameras to save

% create a cell array of all the cameras (to do: move out of config file)
for ncam = 1:length(xpos)
    % rotation matrices

    rx(ncam) = atand(ypos(ncam)/zpos(ncam));    
    rxm = rotx(rx(ncam));

    campos = [xpos(ncam) ypos(ncam) zpos(ncam)]';
    postmp = rxm*[xpos(ncam) ypos(ncam) zpos(ncam)]'; % position in new coordinates

    ry(ncam) = atand(postmp(1)/postmp(3));
    rym = roty(ry(ncam));

    rzm = rotz(rz(ncam));

    % funky sign fix
    rxm = rotx(-rx(ncam));
    rx(ncam)=-rx(ncam);
    
    %rot = rzm*rym*rxm;
    rot = rzm*rxm*rym;

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
occluded=0; % true = occluded, false = no occlusion
body.file = 'Block.stl'; % stl file of body/object
body.scale = 3*0.1; % if stl needs resizing
body.Position = [0 0 10]; % location of body centroid, y+ down right now (image-style coordinates, in mm)
body.Shade = 1; % bright or dark occlusion (1 = bright, 0 = dark)

% display parameters for flow field
displayFlowField=true; %Display image of each flow field,
closeFlowField=false; %and close it automatically

flows={'rankine_vortex'};
% flows={'vortex_ring'};

% configure PIV
bitDepths=8; % leave at 8 bits for all tests
deltaXFactor=0.25; % max. displacement as a fraction of the final window size
particleRadius=5; % in pixels
Ni=1; % # of particles in each window
noiseLevel=0; % turn off noise for now
outOfPlaneStdDeviation=0; % turn off out of plane motion for now
numberOfRuns=1; % number of trials with each parameter set to generate
numberOfFrames = 4; % number of frames (constant dt) to generate in each image sequence (minimum 2 for PIV, minimum 4 for PTV)
winSize = [32]; % interrogation window sizes (final)
sheetThickness = [24]; % light sheet thickness in mm
zWinScale = 1; % scale of z interrogation window size relative to x and y (assumed to be same)
singlePart = 0; % binary, when on generates images of a single particle centered in the volume for normalizing Q

generate3DPIVImagesAllCombinations;
